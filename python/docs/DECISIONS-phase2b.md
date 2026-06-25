# Phase 2B — RAG Pipeline Decisions

**Date:** June 2026
**Milestone:** 2B — RAG pipeline implementation
**Status:** Complete, deployed to Railway

---

## Decision 1: RAG is justified for prose documentation, NOT for transactional data

**Context:** We needed to determine whether RAG was necessary for this domain or whether the existing rule-based + SQL approach was sufficient.

**Investigation:** Examined real production CSV exports across four separate batches (Parsed, Missing, Tenancy, Reconciled-Summary, Reconciled-Transactions, Unmatched). Checked every field for unstructured content, free text, or fuzzy judgment calls.

**Finding:** Every field in the transactional exports was either a closed enum (~8-10 reason codes), a numeric fact, or a deterministically-generated string. Zero free text, zero analyst commentary.

**Validation:** Tested 10 paraphrased questions against prose handbook docs. 9 of 10 would defeat keyword/rule-based search due to vocabulary mismatch between question phrasing and source document wording.

**Decision:** Use RAG exclusively for prose SOP/handbook documentation. Keep SQL/tool-calling for transactional data lookups. Keep rule-based engine for deterministic status explanations.

**Alternatives rejected:**
- RAG over transactional CSVs — would be slower, less accurate than direct SQL
- RAG over everything — over-engineering, no data-driven justification
- No RAG at all — validated that prose documentation genuinely benefits from semantic retrieval

---

## Decision 2: Raw SDK implementation, no LangChain

**Context:** LangChain is the most common RAG framework, but adds abstraction over the underlying mechanism.

**Decision:** Build with direct OpenAI SDK + ChromaDB calls. Defer LangChain as an optional future refactor.

**Rationale:** As a learning project, seeing every vector, every distance score, and every prompt assembly step was more valuable than cleaner code. The raw implementation makes the mechanism fully transparent and debuggable.

**Trade-off accepted:** More verbose code in exchange for complete understanding of the pipeline internals.

---

## Decision 3: Document-structure-aware chunking with section-title enrichment

**Context:** Three chunking strategies were evaluated — fixed-size, semantic (embedding-based split detection), and document-structure-aware (split on markdown headers).

**Decision:** Split on `##` headers, one section = one chunk. Prepend section title to chunk text before embedding.

**Rationale:** Since we author the docs ourselves, we control chunk boundaries by writing discipline — no splitting algorithm needed. The enrichment fix (prepending titles) measurably improved retrieval: distances dropped from 0.55+ to 0.20 for direct matches.

**Alternatives rejected:**
- Fixed-size chunking (500 tokens with overlap) — risks splitting a concept mid-sentence; solves a problem we don't have since docs are short
- Semantic chunking — computationally expensive, overkill for hand-authored, topic-pure documents

---

## Decision 4: ChromaDB for prototyping, pgvector as production path

**Context:** Vector store options include managed services (Pinecone, Weaviate), Postgres extensions (pgvector), and embedded databases (ChromaDB).

**Decision:** ChromaDB for current implementation. pgvector documented as the stated production evolution path.

**Rationale:** ChromaDB is the standard prototyping choice — zero infrastructure, runs embedded, conceptually identical to any larger vector store. pgvector would be the natural evolution for our Rails/Postgres stack (vectors alongside relational data in one database).

**Alternatives rejected:**
- Pinecone/Weaviate — managed services sized for millions of vectors; overkill for 55 chunks
- pgvector immediately — adds infrastructure complexity before the pipeline itself is validated

---

## Decision 5: OpenAI text-embedding-3-small, cosine similarity, top-3 retrieval

**Context:** Standard configuration choices for embedding model, similarity metric, and retrieval depth.

**Decisions:**
- **Embedding model:** `text-embedding-3-small` — industry default, cost-effective, 1536 dimensions
- **Similarity metric:** Cosine — standard for text embeddings, measures direction (meaning) not magnitude
- **Top-k:** 3 — appropriate for a 55-chunk corpus; retrieving more would return near-everything

**Alternatives rejected:**
- Larger embedding models (3-large, Cohere) — optimizing a dimension that isn't the bottleneck at 55 chunks
- Local/open-source embeddings (all-MiniLM-L6-v2) — adds infrastructure complexity for zero benefit when already using OpenAI for LLM calls
- Reranking — corpus is smaller than a typical rerank candidate pool; the technique solves a problem that structurally cannot occur at this scale

---

## Decision 6: Grounded system prompt with explicit refusal instruction

**Context:** The LLM must answer from retrieved context only, not from its general training knowledge, to prevent hallucination.

**Decision:** System prompt includes: "Answer using ONLY the context provided. If the context is clearly unrelated, say you don't have enough information."

**Iteration:** Initial prompt ("If the context does not contain enough information") caused false refusals — the LLM refused to answer Q4 even though the correct chunk was retrieved. Softened to "If the context is clearly unrelated" to reduce over-caution while maintaining the hallucination guard.

**Trade-off:** Slightly higher risk of the LLM stretching a weak match vs. completely refusing valid questions. The softened version tested better across 10 questions.

---

## Decision 7: Source citations in every response

**Context:** Trust and verifiability are important for any RAG system — the user should be able to trace an answer back to its source.

**Decision:** Every `/analyze` response includes a `sources` array with `document`, `section`, and `distance` for each retrieved chunk.

**Rationale:** Low implementation cost (metadata already stored in ChromaDB), high trust payoff, and a strong demo/portfolio moment. Also useful for debugging retrieval quality during development.

---

## Metrics

| Metric | POC (1 doc, 10 chunks) | Production (8 docs, 55 chunks) |
|--------|----------------------|-------------------------------|
| Best retrieval distance | 0.33 (direct match) | 0.20 (direct match with enrichment) |
| Paraphrased question avg distance | 0.55-0.60 | 0.40-0.55 |
| Correct top-1 retrieval | 7/10 | 8/10 |
| False refusals | Not tested | 1/10 (Q4, fixed with prompt adjustment) |
| Content gaps | Not tested | 1/10 (Q9, reversal window concept missing) |
