# frozen_string_literal: true

# FollowUpClassifier
#
# v0.10.0 — Contextual Reuse
#
# PURPOSE:
# Classifies follow-up questions that can be answered
# by projecting fields from a prior ExplanationContract.
#
# DOES NOT:
# - Resolve new intent
# - Access documents
# - Infer meaning
module Engine
  module FollowUp
    class FollowUpClassifier
      BLOCKING_PATTERNS = [
        "block", "blocking", "stop reconciliation"
      ]

      OWNERSHIP_PATTERNS = [
        "who owns", "owner", "responsible", "ownership"
      ]

      COMPLETION_PATTERNS = [
        "complete", "completed", "finished", "final", "terminal"
      ]

      IMPACT_PATTERNS = [
        "impact", "affect", "what happens"
      ]

      OUT_OF_SCOPE_PATTERNS = [
        "fix", "resolve", "how do i", "where do i", "click",
        "enable", "upload", "retry", "why did"
      ]

      LIFECYCLE_NEXT_PATTERNS = [
        "what stage comes after", "what comes next", "what happens after"
      ]

      def classify(input)
        normalized = normalize(input)

        return :out_of_scope if matches?(normalized, OUT_OF_SCOPE_PATTERNS)
        return :blocking_query if matches?(normalized, BLOCKING_PATTERNS)
        return :ownership_query if matches?(normalized, OWNERSHIP_PATTERNS)
        return :completion_query if matches?(normalized, COMPLETION_PATTERNS)
        return :impact_query if matches?(normalized, IMPACT_PATTERNS)
        return :lifecycle_next if matches?(normalized, LIFECYCLE_NEXT_PATTERNS)

        :unknown
      end

      private

      def normalize(text)
        text.to_s.downcase.strip
      end

      def matches?(text, patterns)
        patterns.any? { |pattern| text.include?(pattern) }
      end
    end
  end
end