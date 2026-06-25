# TIL: Building a RAG Pipeline from Scratch — What I Actually Learned

**Date:** June 25, 2026
**Project:** ReconPilot AI — Payment Reconciliation Assistant
**Context:** Phase 2B of adding AI capabilities to a rule-based chatbot

## The Starting Point

I had a working rule-based chatbot (Sinatra engine) that could answer questions about payment reconciliation — but only if the question matched a hardcoded pattern exactly. Phase 2 was about adding an LLM-powered layer. The question was: does this domain actually need RAG, or is it over-engineering?

## The Investigation (Before Writing Any Code)

I spent significant time investigating whether RAG was genuinely justified. I examined real production CSV exports across four separate batches — Parsed, Missing, Tenancy, Reconciled-Summary, Reconciled-Transactions, Unmatched — looking for unstructured data that would benefit from semantic retrieval.

**What I found:** every field in the transactional data was either a closed enum (reason codes like COMMISSION MISMATCH, INVALID SALE), a numeric fact (commission amounts, transaction counts), or a deterministically-generated string (campaign mappings). Zero free text, zero analyst commentary, zero fuzzy judgment calls.

**The conclusion:** for structured transactional data, SQL/tool-calling is the correct approach, not RAG. RAG would be objectively slower, less accurate, and more expensive for exact-match lookups.

**Where RAG was justified:** I tested 10 realistic paraphrased questions against the prose handbook/SOP documentation and found that 9 of 10 would defeat keyword/rule-based search — the question vocabulary shared almost no literal tokens with the source doc's wording, but the meaning clearly mapped to a specific passage. That's the textbook definition of where semantic retrieval earns its place.

**Key learning:** knowing when NOT to use RAG is as important as knowing how to build it. The investigation itself — testing real data, disproving hypotheses, narrowing scope — is a legitimate engineering deliverable.

## The POC (Proving the Mechanism)

Before building the full pipeline, I wrote 5 standalone scripts (step1 through step5) to see each stage in isolation:

1. **Chunking** — splitting a markdown doc on `##` headers. No AI involved, just string splitting. Each section becomes one retrievable unit.

2. **Embedding** — sending chunk text to OpenAI's `text-embedding-3-small` model. What comes back is a list of 1536 floating-point numbers — the chunk's "meaning" represented as a position in mathematical space. Two chunks about similar concepts end up near each other in this space, regardless of which words they use.

3. **Storage** — putting vectors + text + metadata into ChromaDB. Conceptually similar to a search index, but indexed by meaning rather than keywords.

4. **Retrieval** — embedding a question, then finding the nearest stored vectors by cosine similarity. This is where I first saw semantic matching work live: the question "Why is this file showing as done but not really done?" (zero shared keywords with "PARTIAL RECONCILED") came back as the #1 match.

5. **Generation** — feeding retrieved chunks into a GPT-4o prompt with explicit grounding instructions ("answer ONLY from context"). The LLM synthesizes a natural-language answer constrained to what was actually retrieved.

**Key learning from the POC:** with only one document (10 chunks from the same topic), retrieval distances were weak (0.55-0.60) because all chunks were semantically close to each other. The model struggled to differentiate. This improved dramatically with the full 8-doc corpus.

## The Production Build

Refactored the POC into a proper Python module (`rag/`) with five files: `chunker.py`, `embedder.py`, `store.py`, `retriever.py`, `pipeline.py`. Each maps 1:1 to a POC step but with clean imports and proper structure.

**Chunk enrichment fix:** prepending the section title to each chunk's text (so the embedding sees "PARTIAL RECONCILED: A payment file shows PARTIAL RECONCILED when..." instead of just the explanation) measurably improved retrieval — distances dropped from 0.55+ to 0.20 for direct matches. This is a well-known RAG optimization that costs nothing to implement.

**Corpus:** 8 hand-authored markdown documents, 55 total chunks, covering file statuses, bucket classification, missing reason codes, tenancy settlement rules, reconciliation lifecycle, reconcile buttons, commission adjustments, and file upload validations.

**Results across 10 test questions:**
- 3 scored STRONG (distance < 0.4) — genuinely good semantic matches with zero keyword overlap
- 5 scored OK (distance 0.4-0.6) — correct retrieval, usable answers
- 2 edge cases identified (one prompt-sensitivity issue, one content gap) — both with clear fixes

## Architecture Decisions That Mattered

- **Raw SDK over LangChain:** Building with direct OpenAI + ChromaDB calls meant I could see every vector, every distance score, every prompt. Understanding came from visibility, not abstraction.
- **Document-structure-aware chunking over fixed-size:** Since I authored the docs myself, I designed chunk boundaries at `##` headers — no splitting algorithm needed. This is a legitimate, standard approach for curated knowledge bases.
- **ChromaDB for prototyping, pgvector noted as production path:** ChromaDB is the standard learning/prototyping choice. For a Rails/Postgres production stack, pgvector would be the natural evolution — same concepts, different storage backend.
- **No reranking:** With 55 chunks, the entire corpus is smaller than a typical rerank candidate pool. Adding reranking would be implementing a solution to a problem that structurally cannot occur at this scale.

## What Surprised Me

1. **How much the investigation mattered.** I spent more time proving RAG was (and wasn't) needed than actually building it. That ratio felt wrong at first but turned out to be exactly right — building on a validated foundation vs. building on assumption.

2. **How simple the actual mechanism is.** Embeddings are an API call. Storage is a specialized database. Retrieval is cosine similarity. The "magic" is entirely in the embedding model's training — everything around it is plumbing.

3. **How much chunk quality matters.** The single biggest improvement came from prepending section titles to chunk text — a one-line code change. Bad chunking with a great model performs worse than good chunking with a standard model.
