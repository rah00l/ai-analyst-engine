# frozen_string_literal: true

# Represents a registered, authoritative knowledge source.
#
# IMPORTANT:
# - This class intentionally does NOT contain document content.
# - It does NOT know how to fetch documents.
# - It is pure metadata and governance.
#
# Think of this as a catalog entry, not a document.
#
# Phase: v0.6.0
# Responsibility: Declare what knowledge exists and how it may be used later.

module Engine
  module Knowledge
    class KnowledgeSource
      attr_reader :id,
                  :name,
                  :description,
                  :authority_level,
                  :domain_scope,
                  :version,
                  :usage_constraints,
                  :source_pointer

      def initialize(
        id:,
        name:,
        description:,
        authority_level:,
        domain_scope:,
        version:,
        source_pointer:,
        usage_constraints: { read_only: true, explanation_only: true }
      )
        @id                = id
        @name              = name
        @description       = description
        @authority_level   = authority_level
        @domain_scope      = domain_scope
        @version           = version
        @source_pointer    = source_pointer
        @usage_constraints = usage_constraints
      end

      # Indicates whether this source is currently usable.
      # Actual eligibility decisions are made in later milestones.
      def active?
        version.active?
      end
    end
  end
end