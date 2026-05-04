# frozen_string_literal: true

# Performs individual eligibility checks used by the eligibility gate.
#
# This class contains NO retrieval logic and NO AI interaction.
# It only inspects intent, registry metadata, and governance rules.
#
# Phase: v0.6.1
# Responsibility: Rule evaluation, not decision orchestration.

require_relative '../knowledge/knowledge_registry'

module Engine
  module Eligibility
    class KnowledgeEligibilityChecker
      def initialize(knowledge_registry:)
        @knowledge_registry = knowledge_registry
      end

      # Shared default checker instance (read-only, stateless usage)
      def self.default
        @default ||= new(
          knowledge_registry: KnowledgeRegistry.default
        )
      end

      # ------------------------------------------------------------
      # NEW (v0.6.1): Return authoritative sources for a domain
      # ------------------------------------------------------------
      def sources_for_domain(domain)
        @knowledge_registry.find_by_domain(domain)
      end

      # Determines whether the intent type is allowed to consult documentation.
      def intent_eligible?(intent)
        [:definition, :policy, :process].include?(intent)
      end

      # Determines whether authority level is sufficient.
      def authority_sufficient?(sources, intent)
        case intent
        when :policy
          sources.any? { |s| s.authority_level == KnowledgeAuthority::POLICY }
        when :definition
          sources.any? do |s|
            [KnowledgeAuthority::POLICY, KnowledgeAuthority::REFERENCE]
              .include?(s.authority_level)
          end
        else
          false
        end
      end

      # Determines whether documentation defines this category of answer.
      def coverage_defined_for_intent?(intent)
        [:definition, :policy, :process].include?(intent)
      end
    end
  end
end