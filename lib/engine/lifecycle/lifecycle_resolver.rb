# frozen_string_literal: true

require_relative "reconciliation_life_cycle_map"

# ============================================================
# LifecycleResolver
#
# Introduced in: v0.10
#
# PURPOSE:
# - Answer lifecycle sequencing questions using a read-only map
#
# THIS CLASS ANSWERS:
# - "What stage comes after X?"
# - "Is this the final stage?"
#
# THIS CLASS DOES NOT:
# - Explain meaning of a status
# - Provide operational steps
# - Modify lifecycle state
#
# DESIGN PRINCIPLE:
# - Delegates all lifecycle knowledge to ReconciliationLifecycleMap
# - Returns analyst-safe, descriptive responses only
# ============================================================
module Engine
  module Lifecycle
    class LifecycleResolver
      def resolve_next_stage(state)
        # current = explanation_term(explanation)
        next_stage = ReconciliationLifecycleMap.next_stage(state)

        return nil unless next_stage

        "After #{state}, the file proceeds to #{next_stage}."
      end

      def resolve_terminal(explanation)
        current = explanation_term(explanation)

        if ReconciliationLifecycleMap.terminal?(current)
          "This is a terminal lifecycle state."
        else
          "This is not a terminal lifecycle state."
        end
      end

      private

      # ----------------------------------------------------------
      # Extracts the canonical term from ExplanationContract
      # ----------------------------------------------------------
      def explanation_term(explanation)
        explanation.respond_to?(:term) ? explanation.term : nil
      end
    end
  end
end