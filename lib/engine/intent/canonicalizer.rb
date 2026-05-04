# frozen_string_literal: true

require_relative "alias_map"

# Canonicalizer
#
# Responsible only for mapping informal phrases
# to canonical document vocabulary.
module Engine
  module Intent
    class Canonicalizer
      def self.resolve_term(raw_term)
        return nil unless raw_term.is_a?(String)

        normalized = raw_term
          .strip
          .downcase
          .tr("–—-", " ")           # normalize all dashes to spaces
          .gsub(/[^\w\s]/, "")       # remove remaining punctuation
          .gsub(/\s+/, " ")          # collapse whitespace
          .strip

        ALIAS_MAP[normalized]
      end
    end
  end
end