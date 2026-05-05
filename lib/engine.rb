# frozen_string_literal: true

# Root namespace (optional but good practice)
module Engine; end

# require "debug"
# -------------------------
# Context (lowest-level state)
# -------------------------
require_relative "engine/context/analysis_context"

# -------------------------
# Reliability (cross-cutting concerns)
# -------------------------
require_relative "engine/reliability/retry_policy"
require_relative "engine/reliability/latency_budget"
require_relative "engine/reliability/cost_guard"
require_relative "engine/reliability/failure_classification"
require_relative "engine/reliability/safety_fallback"
require_relative "engine/reliability/trust_contract"
require_relative "engine/reliability/ai_call_boundary"

# -------------------------
# Knowledge layer
# -------------------------
require_relative "engine/knowledge/knowledge_version"
require_relative "engine/knowledge/knowledge_domain"
require_relative "engine/knowledge/knowledge_source"
require_relative "engine/knowledge/knowledge_authority"
require_relative "engine/knowledge/knowledge_registry"

# -------------------------
# Eligibility checks
# -------------------------
require_relative "engine/eligibility/knowledge_eligibility_reason"
require_relative "engine/eligibility/knowledge_eligibility_result"
require_relative "engine/eligibility/knowledge_eligibility_checker"
require_relative "engine/eligibility/knowledge_eligibility_gate"

# -------------------------
# Lifecycle
# -------------------------
require_relative "engine/lifecycle/reconciliation_life_cycle_map"
require_relative "engine/lifecycle/lifecycle_resolver"

# -------------------------
# Grounding
# -------------------------
require_relative "engine/grounding/document_adapter"
require_relative "engine/grounding/pdf_document_adapter"
require_relative "engine/grounding/grounded_explanation_controller"

# -------------------------
# Intent processing
# -------------------------
require_relative "engine/intent/intent_contract"
require_relative "engine/intent/alias_map"
require_relative "engine/intent/canonicalizer"
require_relative "engine/intent/intent_resolver"

# -------------------------
# Explanation
# -------------------------
require_relative "engine/explanation/concept_classifier"
require_relative "engine/explanation/explanation_contract"
require_relative "engine/explanation/explanation_builder"

require_relative "engine/templates/mapping_error_template"
require_relative "engine/templates/status_template"
require_relative "engine/templates/terminal_status_template"
require_relative "engine/templates/transitional_status_template"

# -------------------------
# Follow-up & continuity
# -------------------------
require_relative "engine/follow_up/context_store"
require_relative "engine/follow_up/follow_up_classifier"
require_relative "engine/follow_up/projection_resolver"
require_relative "engine/follow_up/boundary_responder"

# -------------------------
# Orchestrator (last)
# -------------------------
require_relative "engine/analyzer"