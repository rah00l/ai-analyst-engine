# frozen_string_literal: true

# Coordinates grounded explanation execution.
#
# Phase 2:
#  - Decides if system may answer
#
# Phase 3:
#  - Decides if knowledge may be consulted (v0.6.1)
#  - Executes document access (v0.7.0)
#
module Engine
  module Grounding
    class GroundedExplanationController
      def initialize(document_adapter:, ai:)
        @document_adapter = document_adapter
        @ai = ai
      end

      # v0.7.3:
      # ----------
      # term must be provided explicitly.
      #
      def explain(context:, eligibility:, source:, section:, version:, term:, system_prompt:, user_prompt:)
        definition =
          @document_adapter.fetch_section(
            source_pointer: source,
            section: section,
            version: version,
            term: term
          )

        unless definition
          return {
            status: "NOT_DEFINED",
            message: "This information is not defined in the authoritative documentation."
          }
        end

        constrained_prompt = <<~PROMPT
          AUTHORITATIVE DEFINITION
          (Source: #{source} #{version}, Section: #{section.to_s.upcase})

          #{term}
          #{definition}

          INSTRUCTION:
          Answer using ONLY the definition above.
          Do not add interpretations, actions, or external knowledge.
        PROMPT

        @ai.explain(
          system_prompt: system_prompt + "\n" + constrained_prompt,
          user_prompt: user_prompt
        )
      end

      private

      def explain_without_docs(system_prompt, user_prompt)
        @ai.explain(
          system_prompt: system_prompt,
          user_prompt: user_prompt
        )
      end

      def not_defined_response
        {
          status: "NOT_DEFINED",
          message: "This information is not defined in the authoritative documentation."
        }
      end
    end
  end
end