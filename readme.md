# ai-analyst-engine

A pure reasoning engine that analyzes natural language input and produces structured explanations.

This repository contains a **pure reasoning engine**.
No UI, no persistence, no external dependencies beyond Ruby standard libraries (adapters excluded).

---

## What the engine does

- Accepts natural language questions
- Resolves intent and canonical domain concepts
- Produces a deterministic, structured explanation output

---

## How to call it

The engine exposes a single public entry point:

```ruby
Engine::Analyzer.analyze(question:, context: {})
````

*   `question` — a natural language string
*   `context` — optional structured metadata (advanced usage)

***

## What it returns

A structured Ruby hash representing the explanation result.

Typical fields include:

*   status
*   type or classification
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

### HTTP API (Sinatra adapter)

Start the service (Docker recommended):

```bash
docker build -t ai-analyst-engine .
docker run --rm -p 4567:4567 ai-analyst-engine
```

Send a request:

```bash
curl -X POST http://localhost:4567/analyze \
  -H "Content-Type: application/json" \
  -d '{"question":"What does PARSED mean?"}'
```
