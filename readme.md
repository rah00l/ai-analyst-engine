# ai-analyst-engine

A pure reasoning engine that analyzes natural language input and produces structured explanations.

This repository contains a **pure reasoning engine**.
No UI, no persistence, no external dependencies beyond Ruby standard libraries (adapters excluded).

---

## What the engine does

- Accepts natural language questions
- Resolves intent and canonical domain concepts
- Produces a deterministic, structured explanation output
- Supports multi-turn follow-up questions when session context is provided

---

## How to call it

The engine exposes a single public entry point:

```ruby
Engine::Analyzer.analyze(question:, context: {})
````

*   `question` — a natural language string
*   `context` — optional structured metadata

For multi-turn or follow-up questions (for example, ownership, impact, or next actions),
callers may provide a `session_id` and a prior explanation via `context`
to enable conversational continuity.

***

## What it returns

A structured Ruby hash representing the explanation result.

Typical fields include:

*   status
*   concept type or classification
*   explanation payload

The exact shape is defined by the explanation contract.

***

## How to run it

### Programmatic usage

```ruby
require "engine"

Engine::Analyzer.analyze(
  question: "What does PARSED mean?"
)
```

***

### HTTP API (Sinatra adapter)

Start the service (Docker recommended):

```bash
docker build -t ai-analyst-engine .
docker run --rm -p 4567:4567 ai-analyst-engine
```

***

### First-turn request

```bash
curl -X POST http://localhost:4567/analyze \
  -H "Content-Type: application/json" \
  -d '{"session_id":"S1","question":"What does PARTIAL RECONCILED mean?"}'
```

***

### Follow-up request (same session)

```bash
curl -X POST http://localhost:4567/analyze \
  -H "Content-Type: application/json" \
  -d '{"session_id":"S1","question":"Does this stop reconciliation?"}'
```

For follow-up questions, the same `session_id` **must be reused**
so the engine can apply the prior explanation as conversational context.

If a new `session_id` is used, the engine treats the request as a new,
independent analysis and follow-up questions may return `NOT_DEFINED`.

***