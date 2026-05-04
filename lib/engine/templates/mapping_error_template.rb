# frozen_string_literal: true

# MappingErrorTemplate
#
# v0.9.0 — Guided Status & Error Workflows
#
# PURPOSE:
# Provides a deterministic explanation strategy for mapping errors.
#
# Mapping errors represent DATA INTEGRITY FAILURES that:
# - block reconciliation
# - require human correction
# - must never be auto-remediated
#
# DESIGN CONSTRAINTS:
# - Explanations must be document-safe
# - No speculative root cause analysis
# - No UI or system instructions
# - No automation logic
#
# MILESTONE CONTEXT:
# Mapping errors could not be explained in v0.7 (grounding-only)
# and v0.8 (intent-only). v0.9 introduces controlled explanation.

require_relative '../explanation_contract'

module Engine
  module Templates
    class MappingErrorTemplate
      def build(term, classification)
        ExplanationContract.new(
          concept_type: classification[:concept_type],
          blocking: classification[:blocking],
          ownership: classification[:ownership],
          meaning: meaning_for(term),
          impact: impact_for(term),
          typical_next_step: typical_next_step_for(term),
          notes: notes_for(term)
        )
      end

      private

      def meaning_for(term)
        "The payment file contains payment identifiers that do not match any existing records in the system."
      end

      def impact_for(term)
        "Because the payments cannot be matched to known records, the file cannot proceed to reconciliation."
      end

      def typical_next_step_for(term)
        "The file is typically corrected to include valid payment identifiers and then re-uploaded for processing."
      end

      def notes_for(term)
        "This error must be resolved before reconciliation can continue."
      end
    end
  end
end