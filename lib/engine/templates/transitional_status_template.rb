# ============================================================
# TransitionalStatusTemplate
#
# Introduced in: v0.10
#
# Purpose:
# - Explain non‑blocking, non‑terminal lifecycle states
# - Provide visibility, not guidance
#
# Design Constraints:
# - Must NOT include operational steps
# - Must NOT suggest UI actions
# - Must remain faithful to handbook semantics
# ============================================================
module Engine
  module Templates
    class TransitionalStatusTemplate
      def build(term, classification)
        case term
        when "NEW"
          build_new(classification)
        when "READY"
          build_ready(classification)
        when "PROCESSING"
          build_processing(classification)
        when "PARSED"
          build_parsed(classification)
        else
          nil
        end
      end

      private

      # ------------------------------------------------------------
      # NEW
      # ------------------------------------------------------------
      def build_new(classification)
        Engine::Explanation::ExplanationContract.new(
          concept_type: classification[:concept_type],
          blocking: false,
          ownership: classification[:ownership],
          meaning:
            "The payment file has been uploaded into the system but processing has not yet started.",
          impact:
            "No parsing or reconciliation activity has occurred at this stage.",
          notes:
            "This is the initial lifecycle state after upload."
        )
      end

      # ------------------------------------------------------------
      # READY
      # ------------------------------------------------------------
      def build_ready(classification)
        Engine::Explanation::ExplanationContract.new(
          concept_type: classification[:concept_type],
          blocking: false,
          ownership: classification[:ownership],
          meaning:
            "The payment file has passed initial validations and is ready to be processed.",
          impact:
            "The system is prepared to begin parsing the file.",
          notes:
            "The file has not yet been reconciled."
        )
      end

      # ------------------------------------------------------------
      # PROCESSING
      # ------------------------------------------------------------
      def build_processing(classification)
        Engine::Explanation::ExplanationContract.new(
          concept_type: classification[:concept_type],
          blocking: false,
          ownership: classification[:ownership],
          meaning:
            "The system is actively processing the payment file.",
          impact:
            "The file is undergoing backend parsing or reconciliation operations.",
          notes:
            "During processing, the lifecycle state may change automatically."
        )
      end

      # ------------------------------------------------------------
      # PARSED
      # ------------------------------------------------------------
      def build_parsed(classification)
        Engine::Explanation::ExplanationContract.new(
          concept_type: classification[:concept_type],
          blocking: false,
          ownership: classification[:ownership],
          meaning:
            "The payment file has been successfully parsed and validated.",
          impact:
            "The file is now eligible to proceed to reconciliation.",
          notes:
            "No reconciliation outcomes have been finalized at this stage."
        )
      end
    end
  end
end
