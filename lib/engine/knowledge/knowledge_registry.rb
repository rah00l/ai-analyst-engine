# frozen_string_literal: true

require_relative "knowledge_version"
require_relative "knowledge_source"
require_relative "knowledge_authority"

# Central registry for all knowledge sources known to the system.
#
# This registry is:
# - Read-only during runtime
# - Global (not session-scoped)
# - Passive (no retrieval, no reasoning)
#
# It is the single source of truth for:
# - What documentation exists
# - What authority it has
# - Which domain it applies to
#
# Phase: v0.6.0
# Responsibility: Governance and inspection ONLY.
#
# Extended in v0.6.1+ to expose a shared default instance.

module Engine
  module Knowledge
    class KnowledgeRegistry
      # ------------------------------------------------------------
      # Phase 3 — Shared registry accessor
      # ------------------------------------------------------------
      def self.default
        @default ||= new.tap(&:register_defaults)
      end

      def initialize
        @sources = {}
      end

      # Registers well-known authoritative knowledge sources.
      # Called only during registry initialization.
      def register_defaults
        register(
          KnowledgeSource.new(
            id: "RECONCILIATION_HANDBOOK",
            name: "Payment Reconciliation Handbook",
            description: "Defines reconciliation statuses, meanings, and rules for payment files.",
            authority_level: KnowledgeAuthority::POLICY,
            domain_scope: [:reconciliation],
            version: ::KnowledgeVersion.new(
              version_id: "v2.1",
              effective_from: Time.utc(2025, 1, 1),
              status: :active
            ),
            source_pointer: "docs/RECONCILIATION_HANDBOOK-v2.1.pdf"
          )
        )
      end

      # Registers a new knowledge source.
      #
      # Typically called during system initialization.
      # Not expected to be called during request handling.
      def register(source)
        @sources[source.id] = source
      end

      # Returns all registered knowledge sources.
      def all_sources
        @sources.values
      end

      # Finds all ACTIVE sources applicable to a given domain.
      def find_by_domain(domain)
        @sources.values.select do |source|
          source.active? && source.domain_scope.include?(domain)
        end
      end

      # Lookup by id (used later for execution and grounding).
      def find_by_id(id)
        @sources[id]
      end
    end
  end
end