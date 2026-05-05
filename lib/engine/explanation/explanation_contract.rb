# frozen_string_literal: true

# ExplanationContract
#
# v0.9.0 — Guided Status & Error Workflows
#
# PURPOSE:
# Defines the formal structure of a guided explanation.
# This contract ensures that all explanations are:
#   - complete
#   - consistent
#   - auditable
#   - safe (no hallucinated guidance)
#
# IMPORTANT DESIGN PRINCIPLES:
# - This struct defines SHAPE only, not behavior.
# - No logic, no inference, no defaults.
# - Every explanation produced in v0.9 MUST conform to this contract.
#
# MILESTONE CONTEXT:
# - v0.7.x determines WHAT is true (grounding)
# - v0.8.0 determines WHAT the user means (intent mediation)
# - v0.9.0 determines HOW the grounded truth is explained to humans
#
# FUTURE NOTE:
# Later milestones (v1.x+, v2.x) may consume this struct
# for UI, automation, or evaluation — do NOT change lightly.
module Engine
  module Explanation
    ExplanationContract = Struct.new(
      :concept_type,        # Symbol — e.g. :status, :status_blocking, :error_mapping
      :blocking,            # true | false | :temporary
      :ownership,           # String — who is responsible (Accounting, Ops, Support)
      :meaning,             # String — document-safe interpretation
      :impact,              # String — what cannot proceed because of this
      :typical_next_step,   # Optional String — generic, non-procedural guidance
      :notes,               # Optional String — caveats or clarifications
      keyword_init: true
    ) do

      # Converts the ExplanationContract into a structured hash
      # suitable for JSON serialization.
      #
      # IMPORTANT:
      # - This controls presentation, not logic.
      # - Do not embed business rules here.
      def to_h
        {
          concept_type: concept_type,
          blocking: blocking,
          ownership: ownership,
          meaning: meaning,
          impact: impact,
          typical_next_step: typical_next_step,
          notes: notes
        }.compact
      end
    end
  end
end
