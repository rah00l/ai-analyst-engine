# ai-analyst-engine

A reasoning engine that analyzes natural language input and produces structured explanations for payment reconciliation queries.

This repository currently runs **two engine implementations**:

- **`python/`** — the **active, current engine**. A FastAPI service using Retrieval-Augmented Generation (RAG) over a curated handbook knowledge base.
- **Ruby (root)** — the **original rule-based engine** that predates the RAG upgrade. Kept here for reference; no longer the primary runtime.

---

## Current Engine — Python / FastAPI / RAG Pipeline

### What it does

- Accepts natural language questions about payment reconciliation (statuses, buckets, missing reasons, tenancy rules, lifecycle, reconcile actions, commissions, file validations)
- Retrieves the most relevant chunks from a curated handbook knowledge base using semantic search
- Generates a grounded, source-cited answer — not a free-form LLM response
- Refuses to answer (rather than guessing) when no chunk is a confident match

### How it works

1. **8 handbook documents** (55 chunks) under `python/rag_docs/` — bucket classification, commission adjustments, file status states, file upload validations, missing reason codes, reconcile buttons, reconciliation lifecycle, tenancy settlement rules
2. **Chunking** (`rag/chunker.py`) — documents are split with section titles prepended to each chunk for improved embedding quality
3. **Embedding** (`rag/embedder.py`) — OpenAI `text-embedding-3-small` generates vectors for each chunk
4. **Storage** (`rag/store.py`) — ChromaDB persists vectors with cosine similarity indexing
5. **Retrieval** (`rag/retriever.py`) — at query time, the question is embedded and the top-3 most similar chunks are retrieved
6. **Generation** (`rag/pipeline.py`) — retrieved chunks are assembled into a grounded prompt and the LLM produces a cited answer
7. **Confidence gate** — if the best retrieval distance exceeds a 0.7 threshold, the engine returns a graceful "I don't know" rather than hallucinating
8. **Evaluation** (`rag/eval.py`) — automated 10-question pass/fail harness verifies retrieval accuracy and confidence-gate behavior on every change

### API

The service exposes:

| Endpoint | Method | Purpose |
|---|---|---|
| `/health` | GET | Liveness check |
| `/ready` | GET | Readiness check |
| `/info` | GET | Service metadata |
| `/analyze` | POST | Main reasoning endpoint |

**Request:**
```bash
curl -X POST http://localhost:8000/analyze \
  -H "Content-Type: application/json" \
  -d '{"session_id":"S1","question":"What does PARSED mean?"}'
```

**Response:**
```json
{
  "session_id": "S1",
  "status": "ok",
  "explanation": "...",
  "sources": [...],
  "concept": "File Status: PARSED",
  "timestamp": "2026-06-28T08:46:28Z"
}
```

### How to run it

**Docker (recommended):**
```bash
cd python
docker build -t ai-analyst-engine .
docker run --rm -p 8000:8000 ai-analyst-engine
```

**Local dev (with auto-reload):**
```bash
cd python
pip install -r requirements.txt
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

> Requires a valid `OPENAI_API_KEY` in your environment for embeddings and generation.

### Key design decisions

See [`python/docs/DECISIONS-phase2b.md`](python/docs/DECISIONS-phase2b.md) for the full record. Summary:

- **RAG is scoped to prose handbook documentation, not transactional data.** Production reconciliation data (statuses, reason codes, commission splits) is deterministic and closed-enum — SQL/tool-calling is the correct approach there, not RAG.
- **Raw SDK over LangChain** — direct OpenAI + ChromaDB calls, for pipeline transparency while learning the underlying mechanics. LangChain refactor is a deferred stretch goal.
- **No reranking** — at 55 chunks, the corpus is too small for reranking to add value.
- **Document-structure-aware chunking** — chunk boundaries are authored deliberately (one concept per `##` section) rather than computed algorithmically, since the handbook docs are hand-written for this purpose.

### Evaluation results

| Metric | Result |
|---|---|
| Test questions | 10 paraphrased queries |
| Retrieval accuracy (correct top-1) | 10/10 |
| Best retrieval distance | 0.20 (direct match, with chunk enrichment) |
| Paraphrased question avg distance | 0.40–0.55 |
| False refusals | 0/10 |
| Off-topic rejection (confidence gate) | Verified on 4 test cases |

Run the harness yourself:
```bash
cd python
python -m rag.eval
```

---

## Legacy Engine — Ruby (Rule-Based)

This is the original implementation, predating the Phase 2 RAG upgrade. It remains in the repo for reference and rollback purposes but is **not the engine currently used in production**.

### What it does

- Accepts natural language questions
- Resolves intent and canonical domain concepts
- Produces a deterministic, structured explanation output
- Supports multi-turn follow-up questions when session context is provided

### How to call it

The engine exposes a single public entry point:

```ruby
Engine::Analyzer.analyze(question:, context: {})
```

- `question` — a natural language string
- `context` — optional structured metadata

For multi-turn or follow-up questions (for example, ownership, impact, or next actions), callers may provide a `session_id` and a prior explanation via `context` to enable conversational continuity.

### What it returns

A structured Ruby hash representing the explanation result. Typical fields include `status`, concept type/classification, and the explanation payload. The exact shape is defined by the explanation contract.

### How to run it

**Programmatic usage:**
```ruby
require "engine"

Engine::Analyzer.analyze(
  question: "What does PARSED mean?"
)
```

**HTTP API (Sinatra adapter):**
```bash
docker build -t ai-analyst-engine-legacy .
docker run --rm -p 4567:4567 ai-analyst-engine-legacy
```

**First-turn request:**
```bash
curl -X POST http://localhost:4567/analyze \
  -H "Content-Type: application/json" \
  -d '{"session_id":"S1","question":"What does PARTIAL RECONCILED mean?"}'
```

**Follow-up request (same session):**
```bash
curl -X POST http://localhost:4567/analyze \
  -H "Content-Type: application/json" \
  -d '{"session_id":"S1","question":"Does this stop reconciliation?"}'
```

For follow-up questions, the same `session_id` must be reused so the engine can apply the prior explanation as conversational context. A new `session_id` is treated as an independent analysis, and follow-up questions may return `NOT_DEFINED`.

---

## Roadmap

- [x] Rule-based reasoning engine (Ruby/Sinatra) — legacy, reference only
- [x] FastAPI scaffold — health/info/ready/analyze endpoints
- [x] RAG pipeline — 8 docs, 55 chunks, ChromaDB, grounded prompts, source citations
- [x] Automated eval harness (10/10) and confidence-gate fallback
- [ ] Query routing (RAG vs SQL/tool-calling, automatic)
- [ ] LangChain refactor for pipeline orchestration
- [ ] pgvector migration (ChromaDB → PostgreSQL)
