# frozen_string_literal: true

# ConceptClassifier
#
# v0.9.0 — Guided Status & Error Workflows
#
# PURPOSE:
# Classifies a canonical, grounded term into a semantic concept type.
#
# This class answers ONE question and ONE question only:
#   "What kind of thing is this?"
#
# It deliberately does NOT:
# - explain meaning
# - infer causes
# - inspect document content
# - interpret user intent
#
# MILESTONE CONTEXT:
# - Grounding (v0.7) already guarantees the term is valid
# - Intent mediation (v0.8) already guarantees correctness of term selection
# - Classification exists ONLY to choose an explanation strategy
#
# EXTENSION RULE:
# When adding new concepts, update classification here —
# never inside templates or explanation builder.
module Engine
  module Explaination
    class ConceptClassifier  
       # ----------------------------------------------------------
       # v0.10 — Transitional (non‑blocking) lifecycle states
       # These represent system progression, not outcomes.
       # ----------------------------------------------------------
       TRANSITIONAL_STATUSES = [
         "NEW",
         "READY",
         "PROCESSING",
         "PARSED"
       ].freeze

      def classify(term)
        case term
        when /MAPPING ERROR/
          {
            concept_type: :error_mapping,
            blocking: true,
            ownership: "Accounting / Operations"
          }

        when "PARTIAL RECONCILED"
          {
            concept_type: :status_blocking,
            blocking: true,
            ownership: "Accounting"
          }

        when "FULL RECONCILED", "RECONCILED"
          {
            concept_type: :status_terminal,
            blocking: false,
            ownership: "System"
          }
        # --------------------------------------------------------
        # v0.10 — Transitional lifecycle states
        # --------------------------------------------------------
        when *TRANSITIONAL_STATUSES
          {
            concept_type: :status_transitional,
            blocking: false,
            ownership: "System"
          }

        else
          # Unknown or unsupported concept for v0.9
          # Caller must handle nil safely
          nil
        end
      end
    end
  end
end