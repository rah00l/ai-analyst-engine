# frozen_string_literal: true

# DocumentAdapter
#
# Defines the execution contract for accessing authoritative documentation.
#
# This class represents an abstract execution boundary.
# It does NOT perform retrieval, parsing, or validation.
#
# Phase: v0.7.0
# Responsibility: Define the execution interface only
module Engine
  module Grounding
    class DocumentAdapter
      # Attempts to fetch an approved section from a document.
      #
      # @param source_pointer [String] Stable reference to the document source
      # @param section [Symbol] Logical section identifier (e.g. :definitions)
      # @param version [String] Document version identifier
      #
      # @return [String, nil]
      #   String → authoritative content found (future milestones)
      #   nil    → content not available (valid outcome)
      def fetch_section(source_pointer:, section:, version:, term:)
        raise NotImplementedError, "Subclasses must implement fetch_section"
      end
    end
  end
end