# ai-analyst-engine

A pure reasoning engine that analyzes text input and produces structured explanations.

This repository contains a **pure reasoning engine**.
No UI, no persistence, no external dependencies beyond Ruby standard libraries (adapters excluded).

---

## What the engine does

- Accepts natural language input
- Resolves intent and domain concepts
- Produces a deterministic, structured explanation output

---

## How to call it

The engine exposes a single public entry point:

```ruby
Engine::Analyzer.analyze(text:, context: {})