# frozen_string_literal: true

require_relative "intent_contract"
require_relative "canonicalizer"

# IntentResolver
#
# Parses user input and emits a canonical Intent object.
# If intent cannot be resolved safely, returns nil.
module Engine
  module Intent
    class IntentResolver
      DEFINITION_PATTERN = /\Awhat does (.+?) mean\??\z/i

      def resolve(user_input)
        return nil unless user_input.is_a?(String)

        match = user_input.strip.match(DEFINITION_PATTERN)
        return nil unless match

        raw_term = match[1]
        canonical_term = Canonicalizer.resolve_term(raw_term)
        return nil unless canonical_term

        Intent.new(
          category: :definition,
          source: "RECONCILIATION_HANDBOOK",
          version: "v2.1",
          section: :definitions,
          term: canonical_term,
          confidence: :high
        )
      end
    end
  end
end