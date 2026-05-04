require_relative 'concept_classifier'

# v0.7 — Grounded error explanations
require_relative '../templates/mapping_error_template'

# v0.9 — System state explanations (blocking + transitional)
require_relative "../templates/status_template"
require_relative "../templates/transitional_status_template"

# v0.9 — Terminal lifecycle states
require_relative "../templates/terminal_status_template"

# ============================================================
# ExplanationBuilder
#
# Role:
# - Produces authoritative explanations for known system concepts
# - Must NEVER hallucinate or infer unknown concepts
#
# Evolution:
# - v0.7  : mapping & parsing errors
# - v0.9  : blocking + terminal lifecycle states
# - v0.10 : transitional lifecycle states (NEW, READY, PARSED, etc.)
#
# Design Rule:
# - If explain(term) returns nil → caller may attempt grounding
# - If explain(term) returns a contract → it is authoritative
# ============================================================
module Engine
  module Explaination
    class ExplanationBuilder
      def initialize
        @classifier = ConceptClassifier.new
      end

      # ------------------------------------------------------------
      # explain(term)
      #
      # Entry point for system‑level explanations.
      # Returns an ExplanationContract or nil.
      #
      # IMPORTANT:
      # - This method must stay deterministic
      # - It must not reason beyond explicit classifications
      # ------------------------------------------------------------
      def explain(term)
        classification = @classifier.classify(term)
        return nil unless classification

        case classification[:concept_type]

        # ----------------------------------------------------------
        # v0.7 — Mapping / parsing error explanations
        # ----------------------------------------------------------
        when :error_mapping
          MappingErrorTemplate.new.build(term, classification)

        # ----------------------------------------------------------
        # v0.9 — Blocking lifecycle states
        # Example: PARTIAL RECONCILED
        # ----------------------------------------------------------
        when :status_blocking
          StatusTemplate.new.build(term, classification)

        # ----------------------------------------------------------
        # v0.9 — Terminal lifecycle states
        # Example: FULL RECONCILED
        # ----------------------------------------------------------
        when :status_terminal
          TerminalStatusTemplate.new.build(term, classification)

        # ----------------------------------------------------------
        # v0.10 — Transitional lifecycle states
        # Example: NEW, READY, PROCESSING, PARSED
        #
        # These are informational states:
        # - Not blocking
        # - Not actionable
        # - Analyst‑focused visibility only
        # ----------------------------------------------------------
        when :status_transitional
          TransitionalStatusTemplate.new.build(term, classification)

        else
          # Concept supported by grounding but not yet modeled
          # in ExplanationBuilder for this milestone
          nil
        end
      end
    end
  end
end