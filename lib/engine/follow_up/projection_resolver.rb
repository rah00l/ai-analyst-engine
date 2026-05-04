# frozen_string_literal: true

# ProjectionResolver
#
# v0.10.0 — Contextual Reuse
#
# PURPOSE:
# Resolves contextual follow-up questions by projecting
# fields from a stored ExplanationContract.
#
# GUARANTEE:
# - No new meaning is introduced
# - No inference or synthesis
# - No operational guidance
module Engine
  module FollowUp
    class ProjectionResolver
      def resolve(classification, explanation)
        case classification
        when :blocking_query
          resolve_blocking(explanation)

        when :ownership_query
          resolve_ownership(explanation)

        when :completion_query
          resolve_completion(explanation)

        when :impact_query
          explanation.impact

        else
          nil
        end
      end

      private

      def resolve_blocking(explanation)
        if explanation.blocking
          "Yes. This blocks reconciliation."
        else
          "No. This does not block reconciliation."
        end
      end

      def resolve_ownership(explanation)
        "This is owned by #{explanation.ownership}."
      end

      def resolve_completion(explanation)
        if explanation.concept_type == :status_terminal
          "Yes. This is a terminal state and reconciliation is complete."
        else
          "No. Reconciliation is not complete."
        end
      end
    end
  end
end