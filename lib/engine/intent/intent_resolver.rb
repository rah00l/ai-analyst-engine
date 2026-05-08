# frozen_string_literal: true

require "yaml"
require_relative "intent_contract"
require_relative "canonicalizer"

# IntentResolver
#
# Parses user input and emits a canonical Intent object.
# If intent cannot be resolved safely, returns nil.
#
# Resolution strategy (two-pass):
#
# Pass 1 — YAML-driven pattern matching
#   Loads question_patterns from concepts.yml.
#   Expands {term} placeholder for each canonical term.
#   Matches against normalised user input.
#   Zero Ruby changes needed to add new phrasings — edit YAML only.
#
# Pass 2 — Alias map fallback
#   Handles messy/compound inputs like:
#   "what does mapping error payment id not found mean?"
#   where the term itself needs normalisation via the alias map.
#
# If both passes fail — returns nil (caller receives NOT_DEFINED).

module Engine
  module Intent
    class IntentResolver
      CONCEPTS_PATH = File.expand_path(
        "../../../../resources/accounting/concepts.yml",
        __FILE__
      )

      # Loaded once at class load time — not per request.
      # YAML owns all phrasing choices. Ruby does not.
      QUESTION_PATTERNS = YAML.load_file(CONCEPTS_PATH).freeze

      def resolve(user_input)
        return nil unless user_input.is_a?(String)

        # --------------------------------------------------------
        # Normalise input once — applied to both passes
        # --------------------------------------------------------
        normalized = user_input
          .downcase
          .strip
          .gsub(/[?\.!]+$/, "")  # strip trailing punctuation
          .gsub(/\s+/, " ")       # collapse whitespace

        # --------------------------------------------------------
        # Pass 1 — YAML-driven pattern matching
        #
        # For each canonical term, expand each pattern by replacing
        # {term} with the escaped lowercase canonical name.
        # Match against the normalised input.
        # --------------------------------------------------------
        QUESTION_PATTERNS.each do |term, concept|
          # Skip aliases and any non-concept entries
          next unless concept.is_a?(Hash)
          next unless concept.key?("question_patterns")

          Array(concept["question_patterns"]).each do |pattern|
            next unless pattern.is_a?(String)

            expanded = pattern
              .downcase
              .gsub("{term}", Regexp.escape(term.downcase))

            return build_intent(term) if /\A#{expanded}\z/.match?(normalized)
          end
        end

        # --------------------------------------------------------
        # Pass 2 — Alias map fallback
        #
        # Handles compound or aliased terms inside "what does X mean"
        # phrasing where X itself needs canonicalisation.
        # Example: "what does mapping error payment id not found mean"
        # --------------------------------------------------------
        match = /\Awhat does (.+?) mean\z/.match(normalized)
        if match
          canonical = Canonicalizer.resolve_term(match[1])
          return build_intent(canonical) if canonical
        end

        # --------------------------------------------------------
        # Both passes failed — caller handles NOT_DEFINED
        # --------------------------------------------------------
        nil
      end

      private

      def build_intent(term)
        Intent.new(
          category:   :definition,
          source:     "RECONCILIATION_HANDBOOK",
          version:    "v2.1",
          section:    :definitions,
          term:       term,
          confidence: :high
        )
      end
    end
  end
end