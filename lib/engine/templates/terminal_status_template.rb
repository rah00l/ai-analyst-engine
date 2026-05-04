# frozen_string_literal: true

# TerminalStatusTemplate
#
# v0.9.0 — Guided Status & Error Workflows
#
# PURPOSE:
# Provides guided explanations for terminal system statuses.
#
# Terminal statuses represent COMPLETED lifecycle states.
# They indicate that no further processing or user action is required.
#
# DESIGN CONSTRAINTS:
# - Must not suggest next steps
# - Must not trigger workflows
# - Must not reopen reasoning chains
#
# MILESTONE CONTEXT:
# - v0.7 grounding confirms the terminal status authoritatively
# - v0.8 intent mediation resolves the user’s question
# - v0.9 formats the terminal meaning safely for humans
#
# This template currently supports:
# - FULL_RECONCILED
module Engine
  module Templates
    class TerminalStatusTemplate
      def build(term, classification)
        case term
        when "FULL RECONCILED"
          build_full_reconciled(classification)
        else
          nil
        end
      end

      private

      def build_full_reconciled(classification)
        ExplanationContract.new(
          concept_type: classification[:concept_type],
          blocking: false,
          ownership: classification[:ownership],
          meaning:
            "The payment file has been fully reconciled, and all associated transactions and tenancies have been successfully processed.",
          impact:
            "Reconciliation is complete and no further processing is required.",
          notes:
            "This is a terminal state. No additional action is needed."
        )
      end
    end
  end
end
