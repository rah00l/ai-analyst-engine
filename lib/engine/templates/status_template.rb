# frozen_string_literal: true

# StatusTemplate
#
# v0.9.0 — Guided Status & Error Workflows
#
# PURPOSE:
# Provides guided explanations for non-error system statuses.
#
# Statuses represent VALID system states, not failures.
# They may still be blocking or require follow-up, but:
# - they are not errors
# - they must not trigger remediation workflows
#
# MILESTONE CONTEXT:
# - v0.7.x provides raw, authoritative status definitions
# - v0.8.0 resolves user intent to a canonical term
# - v0.9.0 adds structured explanations for selected statuses
#
# This template currently supports:
# - PARTIAL_RECONCILED
#
# Extension rule:
# - New statuses must be explicitly added
# - Do NOT infer behavior from naming or text

module Engine
  module Templates
    class StatusTemplate
      def build(term, classification)
        case term
        when "PARTIAL RECONCILED"
          build_partial_reconciled(classification)
        else
          # Unsupported status for v0.9
          nil
        end
      end

      private

      def build_partial_reconciled(classification)
        ExplanationContract.new(
          concept_type: classification[:concept_type],
          blocking: classification[:blocking],
          ownership: classification[:ownership],
          meaning:
            "The file has been partially reconciled, meaning some transactions have been reconciled while others remain unsettled.",
          impact:
            "Because not all tenancies are settled, the reconciliation process is not yet complete.",
          typical_next_step:
            "Outstanding tenancies are typically reviewed and settled to complete reconciliation.",
          notes:
            "Full reconciliation cannot be achieved until all pending tenancies are settled."
        )
      end
    end
  end
end
