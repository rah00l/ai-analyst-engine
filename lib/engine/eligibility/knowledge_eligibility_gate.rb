# frozen_string_literal: true

# Central gate that decides whether documentation
# is allowed to be consulted for a given question.
#
# IMPORTANT:
# - This gate DOES NOT perform retrieval.
# - This gate DOES NOT change responses.
# - This gate ONLY returns an explicit decision.
#
# Phase: v0.6.1
# Responsibility: Permission gating.

require_relative "knowledge_eligibility_checker"
require_relative "knowledge_eligibility_result"
require_relative "knowledge_eligibility_reason"


module Engine
  module Eligibility
    class KnowledgeEligibilityGate
      # ------------------------------------------------------------
      # Entry point used by the console (Phase 7.0 execution fork)
      # ------------------------------------------------------------
      def self.evaluate(intent:, domain:)
        checker = KnowledgeEligibilityChecker.default

        normalized_intent = normalize_intent(intent)

        unless checker.intent_eligible?(normalized_intent)
          return KnowledgeEligibilityResult.new(
            allowed: false,
            reason: KnowledgeEligibilityReason::INTENT_NOT_ELIGIBLE
          )
        end
        sources = checker.sources_for_domain(domain)

        if sources.empty?
          return KnowledgeEligibilityResult.new(
            allowed: false,
            reason: KnowledgeEligibilityReason::NO_KNOWLEDGE_SOURCE
          )
        end

        unless checker.authority_sufficient?(sources, normalized_intent)
          return KnowledgeEligibilityResult.new(
            allowed: false,
            reason: KnowledgeEligibilityReason::INSUFFICIENT_AUTHORITY
          )
        end

        unless checker.coverage_defined_for_intent?(normalized_intent)
          return KnowledgeEligibilityResult.new(
            allowed: false,
            reason: KnowledgeEligibilityReason::COVERAGE_NOT_DEFINED
          )
        end

        KnowledgeEligibilityResult.new(
          allowed: true,
          reason: KnowledgeEligibilityReason::ALLOWED
        )
      end

      # ------------------------------------------------------------
      # Phase 5 → Phase 6 intent normalization
      #
      # Converts conversational intents into knowledge categories.
      # This mapping is explicit and auditable by design.
      # ------------------------------------------------------------
      def self.normalize_intent(intent)
        case intent
        when :status_meaning
          :definition
        when :next_action
          :process
        when :error_meaning
          :causality
        else
          intent
        end
      end

      private_class_method :normalize_intent
    end
  end
end