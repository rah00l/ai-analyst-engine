# frozen_string_literal: true

# Enumerates explicit reasons why knowledge retrieval is allowed or denied.
#
# These reasons are NOT user-facing yet;
# they exist for governance, logging, and future explanation.
#
# Phase: v0.6.1
# Responsibility: Explainability of decisions.

module Engine
  module Eligibility
    module KnowledgeEligibilityReason
      ALLOWED = :allowed

      INTENT_NOT_ELIGIBLE        = :intent_not_eligible
      NO_KNOWLEDGE_SOURCE       = :no_knowledge_source
      INSUFFICIENT_AUTHORITY    = :insufficient_authority
      DOMAIN_MISMATCH           = :domain_mismatch
      COVERAGE_NOT_DEFINED      = :coverage_not_defined
    end
  end
end