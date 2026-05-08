Let me read both files carefully before answering.Reading the AI engine strategy fileReading the AI engine strategy fileNow let me read the gitingest to map exactly what files exist and what moves where.Reading gitingest - directory structure and key filesReading gitingest - directory structure and key filesNow let me read the v0.9 milestone files — the most current — to map exactly which files move to the engine.Reading milestone 08 and 09 file structure in detailReading milestone 08 and 09 file structure in detailI now have everything. Let me build the complete answer to all four questions.
  ::view-transition-group(*),
  ::view-transition-old(*),
  ::view-transition-new(*) {
    animation-duration: 0.25s;
    animation-timing-function: cubic-bezier(0.19, 1, 0.22, 1);
  }


Question 1 — Is the approach right?
What is confirmed ✓
Two repos — engine + demo — correct split
Sinatra as HTTP adapter only — right decision
Tailwind CSS — right choice, ships well with Rails 7
Minimal README for engine — exactly right
Read-only screens + fictional data — correct
What you are NOT building list — perfectly scoped
What needs adjustment →
Strategy 3 folder structure needs expansion — your engine has 30+ files, not 4. The minimal view hides important architecture. Expand it.
Strategy 4 README — correct rule but also add an architecture diagram. One diagram communicates what 10 paragraphs can't.
The engine name "ai-explanation-engine" is fine internally but for portfolio rename to something more specific: reconciliation-ai-engine or ai-analyst-engine. More searchable, more memorable.


Question 2 — Exact file extraction map from your gitingest (09-contextual-reuse = source of truth)
Source: ruby/09-contextual-reuse/ — your most current milestone
Every file in v0.11 (09-contextual-reuse) is classified below. Green = moves to engine repo. Blue = new file to create. Red = drop entirely. Gray = stays in journey repo only.
Moves to engine
New file (create)
Drop (infra/console only)
Stays in journey repo
── Core engine (lib/engine/)
✓ analyzer.rb <-- NEW: orchestrator wrapping the pipeline below
✓ intent_resolver.rb <-- from 07-intent-mediation/intent_resolver.rb
✓ canonicalizer.rb <-- from 09-contextual-reuse/canonicalizer.rb
✓ alias_map.rb <-- from 09-contextual-reuse/alias_map.rb
✓ intent_contract.rb <-- from 09-contextual-reuse/intent_contract.rb
✓ concept_classifier.rb <-- from 09-contextual-reuse/concept_classifier.rb
✓ explanation_builder.rb <-- from 09-contextual-reuse/explanation_builder.rb
✓ explanation_contract.rb <-- from 09-contextual-reuse/explanation_contract.rb
✓ follow_up_classifier.rb <-- from 09-contextual-reuse/follow_up_classifier.rb
✓ projection_resolver.rb <-- from 09-contextual-reuse/projection_resolver.rb
✓ context_store.rb <-- from 09-contextual-reuse/context_store.rb
✓ boundary_responder.rb <-- from 09-contextual-reuse/boundary_responder.rb

── Reliability (lib/engine/reliability/)
✓ ai_call_boundary.rb <-- from 09-contextual-reuse/ai_call_boundary.rb
✓ retry_policy.rb <-- from 09-contextual-reuse/retry_policy.rb
✓ cost_guard.rb <-- from 09-contextual-reuse/cost_guard.rb
✓ latency_budget.rb <-- from 09-contextual-reuse/latency_budget.rb
✓ failure_classification.rb <-- from 09-contextual-reuse/failure_classification.rb
✓ safety_fallback.rb <-- from 09-contextual-reuse/safety_fallback.rb
✓ trust_contract.rb <-- from 09-contextual-reuse/trust_contract.rb

── Context (lib/engine/context/)
✓ analysis_context.rb <-- from context/analysis_context.rb

── Knowledge (lib/engine/knowledge/)
✓ knowledge_authority.rb
✓ knowledge_domain.rb
✓ knowledge_registry.rb
✓ knowledge_source.rb
✓ knowledge_version.rb

── Eligibility (lib/engine/eligibility/)
✓ knowledge_eligibility_gate.rb
✓ knowledge_eligibility_checker.rb
✓ knowledge_eligibility_reason.rb
✓ knowledge_eligibility_result.rb

── Grounding (lib/engine/grounding/)
✓ grounded_explanation_controller.rb
✓ document_adapter.rb <-- from adapter/
✓ pdf_document_adapter.rb <-- from adapter/

── Lifecycle (lib/engine/lifecycle/)
✓ lifecycle_resolver.rb
✓ reconciliation_life_cycle_map.rb

── Templates (lib/engine/templates/)
✓ mapping_error_template.rb
✓ status_template.rb
✓ terminal_status_template.rb
✓ transitional_status_template.rb

── Resources (resources/accounting/)
+ concepts.yml <-- NEW: extract alias_map data into YAML config
+ lifecycle.yml <-- NEW: extract lifecycle map into YAML config
✓ handbook PDF <-- your existing handbook document

── Sinatra adapter (sinatra/)
+ app.rb <-- NEW: POST /analyze → Engine::Analyzer.analyze(q) → JSON
+ config.ru <-- NEW: Rack mount

── Entry point
+ lib/engine.rb <-- NEW: single require file — loads entire engine
+ bin/console <-- NEW: thin console wrapper for local testing

── Drop entirely (console + infra only)
ai_structured_console.rb <-- console runner, not engine logic
Dockerfile (milestone copies) <-- replaced by engine Dockerfile
docker-compose.yml (milestone copies)
.env.example (milestone copies) <-- one at root of engine repo


Question 3 — Complete engine folder structure (corrected from your Strategy 3)
ai-analyst-engine/ — complete layout
Your Strategy 3 had 4 files. The real engine has 35. This is the correct minimalist layout — every folder exists for a reason, nothing extra.
ai-analyst-engine/
├── lib/
│ ├── engine.rb ← single require entry point
│ └── engine/
│ ├── analyzer.rb ← NEW: top-level orchestrator
│ ├── context/
│ │ └── analysis_context.rb
│ ├── intent/
│ │ ├── alias_map.rb
│ │ ├── canonicalizer.rb
│ │ ├── intent_contract.rb
│ │ └── intent_resolver.rb
│ ├── knowledge/
│ │ ├── knowledge_authority.rb
│ │ ├── knowledge_domain.rb
│ │ ├── knowledge_registry.rb
│ │ ├── knowledge_source.rb
│ │ └── knowledge_version.rb
│ ├── eligibility/
│ │ ├── knowledge_eligibility_gate.rb
│ │ ├── knowledge_eligibility_checker.rb
│ │ ├── knowledge_eligibility_reason.rb
│ │ └── knowledge_eligibility_result.rb
│ ├── grounding/
│ │ ├── grounded_explanation_controller.rb
│ │ ├── document_adapter.rb
│ │ └── pdf_document_adapter.rb
│ ├── explanation/
│ │ ├── concept_classifier.rb
│ │ ├── explanation_builder.rb
│ │ ├── explanation_contract.rb
│ │ └── templates/
│ │ ├── mapping_error_template.rb
│ │ ├── status_template.rb
│ │ ├── terminal_status_template.rb
│ │ └── transitional_status_template.rb
│ ├── follow_up/
│ │ ├── boundary_responder.rb
│ │ ├── context_store.rb
│ │ ├── follow_up_classifier.rb
│ │ └── projection_resolver.rb
│ ├── lifecycle/
│ │ ├── lifecycle_resolver.rb
│ │ └── reconciliation_life_cycle_map.rb
│ └── reliability/
│ ├── ai_call_boundary.rb
│ ├── cost_guard.rb
│ ├── failure_classification.rb
│ ├── latency_budget.rb
│ ├── retry_policy.rb
│ ├── safety_fallback.rb
│ └── trust_contract.rb
├── resources/
│ └── accounting/
│ ├── concepts.yml ← NEW: alias map as config
│ ├── lifecycle.yml ← NEW: lifecycle map as config
│ └── documents/
│ └── handbook.pdf ← your existing handbook
├── sinatra/
│ ├── app.rb ← NEW: POST /analyze endpoint
│ └── config.ru ← NEW: Rack mount
├── bin/
│ └── console ← NEW: local test console
├── Gemfile
├── Dockerfile
├── docker-compose.yml
├── .env.example
└── README.md

Question 4 — Git commit / branch / tag strategy — locked
Decision: Milestone-based tags + task-based commits — hybrid
Your existing journey repo uses milestone-based tags (v0.1.0 through v0.11.0) — this discipline is your strongest portfolio signal. Keep it. For the two new repos the strategy is: task-based commits within a milestone, milestone tag at completion. This matches how real teams work and how your journey has already proven itself.

Repo 1: ai-analyst-engine — branch + tag strategy

branch: main
Protected. Only receives merges from feature branches. Never commit directly.

branch: setup
Initial scaffold, Gemfile, Dockerfile, .env.example, README skeleton. Merge → tag v1.0.0-scaffold

branch: extract-core
Move all 35 files from journey repo into correct engine folders. One commit per logical group: intent/, knowledge/, eligibility/, etc. Merge → tag v1.0.0-core

branch: add-orchestrator
Write Engine::Analyzer — the single public entry point. Write lib/engine.rb require chain. Merge → tag v1.0.0-orchestrator

branch: sinatra-adapter
Write sinatra/app.rb — POST /analyze → Engine::Analyzer.analyze → JSON. Write config.ru. Local test. Merge → tag v1.0.0-api

branch: resources
Extract alias_map into concepts.yml. Extract lifecycle_map into lifecycle.yml. Update engine to load from YAML. Merge → tag v1.0.0-resources
tag: v1.0.0 RELEASE

Engine is complete, tested via bin/console, Sinatra endpoint live. This is the version the demo app depends on.

Repo 2: ai-reconciliation-demo — branch + tag strategy
branch: setup
rails new, Tailwind, Gemfile, Dockerfile. Merge → tag v0.1.0-scaffold
branch: seed-data
Models: PaymentFile, Transaction, Merchant. db/seeds.rb with fictional data. Merge → tag v0.1.0-data
branch: screens-1-2
Upload list screen + Display screen. Read-only. Tailwind tables. Merge → tag v0.2.0-screens-1-2
branch: screens-3-4-5
Missing screen (colour-coded rows) + Tenancy + Final summary. Merge → tag v0.3.0-screens-3-4-5
branch: chat-integration
Stimulus chat controller. POST /analyze to engine. Turbo Stream renders ExplanationContract. Chat widget on all screens. Merge → tag v0.4.0-chat
branch: deploy
Render.com config, Docker Compose end-to-end test, README with live link + demo GIF. Merge → tag v0.5.0-live
tag: v1.0.0 PORTFOLIO RELEASE
Both repos live. Demo recorded. README complete. This is the version you share with hiring managers.
Commit message format — lock this convention
feat(intent): add alias_map extraction to concepts.yml
feat(sinatra): add POST /analyze endpoint with JSON response
refactor(engine): introduce Engine::Analyzer orchestrator
refactor(grounding): reorganise adapter into grounding/ subfolder
fix(eligibility): correct DENY reason when domain mismatch
docs(readme): add architecture diagram and live demo link
chore(docker): update compose for two-service engine + demo
Format: type(scope): description — conventional commits standard. Makes your git log readable to any engineer who reviews the repo.

Locked decisions — four answers
Q1
Approach is correct. Two corrections: rename engine repo, add architecture diagram to README.
Q2
35 files move from 09-contextual-reuse. Source of truth is your latest milestone. 4 new files to create: analyzer.rb, engine.rb, sinatra/app.rb, config.ru. 2 YAML configs to extract. Drop all console runners and milestone-specific Dockerfiles.
Q3
Engine structure is 8 logical subfolders under lib/engine/. Your Strategy 3 had 4 files — expanded to the correct 35. Every folder maps to a concept you already built.
Q4
Hybrid strategy locked: task-based commits (feat/refactor/fix/docs/chore) within feature branches, milestone tag at each branch merge. Engine: 6 branches → v1.0.0. Demo: 5 branches → v1.0.0. Conventional commits format throughout.



## The three things worth discussing before you start

**First — the `Engine::Analyzer` orchestrator is the most important new file.** Everything else already exists in your journey repo. This is the one genuinely new piece of work. It is the single public interface of the entire engine — it takes a question string, runs it through the full pipeline (intent → eligibility → grounding → explanation → follow-up or lifecycle), and returns an `ExplanationContract` as JSON. The Sinatra adapter is literally just: receive HTTP POST, call `Engine::Analyzer.analyze(question)`, return the result. That's the complete integration.

**Second — extract alias_map and lifecycle_map into YAML configs.** Right now these are Ruby hashes hardcoded inside `.rb` files. Moving them to `concepts.yml` and `lifecycle.yml` under `resources/accounting/` does two things: it makes your engine genuinely domain-agnostic (swap the YAML, get a different domain), and it makes a much stronger portfolio point — you separated configuration from code. In an interview this is a one-sentence explanation that shows senior thinking.

**Third — on the `bin/console`.** This is your existing `ai_structured_console.rb` rewritten as a clean entry point that loads `lib/engine.rb` and drops into an IRB session. It lets anyone clone the engine repo and run `bin/console` to test it locally without the demo app. This is standard Ruby gem practice and makes your engine feel like a real library, not a script.

The order of work is: build engine repo first (2 days), confirm `bin/console` works end to end, then start the demo Rails app knowing the engine is stable. Do not build both simultaneously.

Ready to start? I can give you the exact code for `Engine::Analyzer`, `lib/engine.rb`, and `sinatra/app.rb` — the three new files that complete the engine.