# frozen_string_literal: true

# Defines the domain scope in which a knowledge source applies.
#
# Domain scoping is a critical safety boundary:
# it prevents cross-domain misuse of documentation
# (e.g., using reconciliation policy to explain settlement logic).
#
# Phase: v0.6.0
# Responsibility: Applicability enforcement.

module Engine
  module Knowledge
    module KnowledgeDomain
      RECONCILIATION = :reconciliation
      SETTLEMENT     = :settlement
      ACCOUNTING     = :accounting
    end
  end
end