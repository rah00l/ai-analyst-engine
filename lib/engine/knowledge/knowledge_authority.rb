# frozen_string_literal: true

# Defines how authoritative a knowledge source is.
#
# This is a governance construct, not business logic.
# It allows later phases (v0.6.1 / v0.7.0) to enforce
# stricter rules for POLICY documents vs REFERENCE or GUIDANCE.
#
# Phase: v0.6.0 (Knowledge Source Registration)
# Responsibility: Trust semantics ONLY.

module Engine
  module Knowledge
    module KnowledgeAuthority
      POLICY    = :policy     # Defines mandatory rules / regulations
      REFERENCE = :reference  # Defines meanings, terminology
      GUIDANCE  = :guidance   # Best practices, non-binding
    end
  end
end