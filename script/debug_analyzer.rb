require_relative "../lib/engine"

session_id = "DEBUG_S1"

puts "---- STEP 1: base explanation ----"
res1 = Engine::Analyzer.analyze(
  question: "Explain PARSED",
  context: { session_id: session_id }
)
puts res1


# curl -X POST http://localhost:4567/analyze \
#   -H "Content-Type: application/json" \
#   -d '{"session_id":"S1","question":"Explain PARSED"}'

# ✅ STORE ONLY THE EXPLANATION CONTRACT
# prior_explanation = res1[:result]

# puts "\n---- STEP 2: follow-up (does NOT update context) ----"
# res2 = Engine::Analyzer.analyze(
#   question: "Does this stop reconciliation?",
#   context: {
#     session_id: session_id,
#     prior_explanation: prior_explanation
#   }
# )
# puts res2

# puts "\n---- STEP 3: second follow-up (ownership) ----"
# res3 = Engine::Analyzer.analyze(
#   question: "Who is responsible for resolving this?",
#   context: {
#     session_id: session_id,
#     prior_explanation: prior_explanation   # ✅ SAME object
#   }
# )
# puts res3

# puts "\n---- STEP 4: third follow-up (impact) ----"
# res4 = Engine::Analyzer.analyze(
#   question: "What happens if I do nothing?",
#   context: {
#     session_id: session_id,
#     prior_explanation: prior_explanation   # ✅ SAME object
#   }
# )
# puts res4

# curl -X POST http://localhost:4567/analyze \
#   -H "Content-Type: application/json" \
#   -d '{"session_id":"S1","question":"What does PARTIAL RECONCILED mean?"}'

# # {"result":{"status":"SUCCESS","result":{"concept_type":"status_blocking","blocking":true,"ownership":"Accounting","meaning":"The file has been partially reconciled, meaning some transactions have been reconciled while others remain unsettled.","impact":"Because not all tenancies are settled, the reconciliation process is not yet complete.","typical_next_step":"Outstanding tenancies are typically reviewed and settled to complete reconciliation.","notes":"Full reconciliation cannot be achieved until all pending tenancies are settled."}}}%                                                                                                    

# curl -X POST http://localhost:4567/analyze \
#   -H "Content-Type: application/json" \
#   -d '{"session_id":"S1","question":"Does this stop reconciliation?"}'

# # {"result":{"status":"SUCCESS","result":"Yes. This blocks reconciliation."}}%                                                                                                                                          

# curl -X POST http://localhost:4567/analyze \
#   -H "Content-Type: application/json" \
#   -d '{"session_id":"S1","question":"Who is responsible for resolving this?"}'


# curl -X POST http://localhost:4567/analyze \
#   -H "Content-Type: application/json" \
#   -d '{"session_id":"S1","question":"What happens if I do nothing?"}'
# {"result":{"status":"SUCCESS","result":{"status":"NOT_DEFINED","message":"This question could not be answered from the reconciliation knowledge base."}}}%        


# # script/debug_analyzer.rb
# require_relative "../lib/engine"

# puts Engine::Analyzer.analyze(
#   question: "What does PARTIAL RECONCILED mean?"
# )



# Canonical Mapping Error
# What does MAPPING ERROR – Payment ID Not Found mean?

# Alias Robustness
# What does mapping error payment id not found mean?
# What does payment id not found mean?
# Does this stop reconciliation?


# File‑level statuses
# What does NEW mean?
# What does READY mean?
# What does PROCESSING mean?
# What does PARSED mean?
# What does RECONCILING mean?
# What does FULL RECONCILED mean?
# What does PARTIAL RECONCILED mean?

# Error statuses
# What does MAPPING ERROR – Payment ID Not Found mean?
# What does MAPPING ERROR – Data Format Issue mean?
# What does PARSING ERROR – Please Contact Support mean?
# What does RECONCILING ERROR – Please Contact Support mean?

# CATEGORY 1 — Definition & Status Meaning (Ground Truth)
# These MUST be stable across phases.
# File‑level statuses
# What does NEW mean?
# What does READY mean?
# What does PROCESSING mean?
# What does PARSED mean?
# What does RECONCILING mean?
# What does FULL RECONCILED mean?
# What does PARTIAL RECONCILED mean?

# CATEGORY 2 — Impact & Consequence (v0.10 Projection)
# Does this block reconciliation?
# Is reconciliation complete in this state?
# Can the file move forward from here?

# What happens if this is not resolved?
# What is the impact on reconciliation?
# What remains pending?

# CATEGORY 3 — Ownership & Responsibility
# Who is responsible for resolving this?
# Is this owned by the system or accounting?
# Does support need to be involved?


# CATEGORY 4 — Lifecycle Reasoning (Conceptual Flow)
# What stage comes after PARSED?
# What does PARTIAL RECONCILED indicate in the lifecycle?
# Is FULL RECONCILED a terminal state?

# CATEGORY 5 — Comparative Reasoning (High‑Value Analyst Use)
# What is the difference between PARTIAL RECONCILED and FULL RECONCILED?
# How is MAPPING ERROR different from PARSING ERROR?
# How is TRAN RECONCILING different from RECONCILING?

# CATEGORY 6 — “What If” / Counterfactual (Boundary Tests)
# What happens if a file stays in PARTIAL RECONCILED?
# What does it mean if reconciliation never completes?
# What happens if multiple payment IDs exist?

# CATEGORY 7 — Explicit Boundary Enforcement (Should Refuse)
# What should I do next?
# How do I fix this error?
# Which button should I click?
# Can I re-upload the file?
# How do I reconcile tenancy?

# CATEGORY 8 — Follow‑Up Chains (v0.10 Stress Test)
# What does MAPPING ERROR – Payment ID Not Found mean?
# → Does this block reconciliation?
# → Who owns this?
# → What happens if nothing is done?

# Another chain:
# What does PARTIAL RECONCILED mean?
# → Is reconciliation complete?
# → What remains pending?
# → Who is responsible?

# CATEGORY 9 — Next‑Phase (v1.x Preview Questions)
# Why are some tenancies left unsettled?
# What determines whether reconciliation is partial?
# What causes tenancy mismatches?



# curl -X POST http://localhost:4567/analyze \
#   -H "Content-Type: application/json" \
#   -d '{"question":"What does MAPPING ERROR – Payment ID Not Found mean?"}'

# curl -X POST http://localhost:4567/analyze \
#   -H "Content-Type: application/json" \
#   -d '{"question":"What does MAPPING ERROR – Payment ID Not Found mean?"}'