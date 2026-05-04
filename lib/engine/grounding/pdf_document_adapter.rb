# frozen_string_literal: true

require_relative "document_adapter"

# PdfDocumentAdapter
#
# Concrete execution adapter for PDF-based documentation.
#
# v0.7.0 responsibility:
# - Exist as a concrete adapter implementation
# - Be invoked when knowledge usage is permitted
# - Return a deterministic execution result
#
# IMPORTANT:
# - This version DOES NOT read files
# - This version DOES NOT parse PDFs
# - Returning nil is a valid and expected outcome
#
# Later milestones will extend this adapter incrementally:
# - v0.7.1: Source pointer resolution (file existence)
# - v0.7.2: Section identification (definitions, policies)
# - v0.7.3: Term-level grounded extraction
#
# Phase: v0.7.0
# Responsibility: Execution plumbing only
module Engine
  module Grounding
    class PdfDocumentAdapter < DocumentAdapter
      # Explicitly declared section headers.
      # These represent the authoritative structure authored by humans.

      # ============================================================
       # v0.7.2 — SECTION IDENTIFICATION
       # ============================================================
       # Explicitly declared section headers.
       # These represent the authoritative structure authored by humans.
       #
       # NOTE:
       # - This is where v0.7.2 officially begins
       # - Structure is introduced BEFORE semantics
      SECTION_HEADERS = {
        definitions: /^(definitions|definition)\b/i,
        status_codes: /^(status codes?)\b/i,
        policies: /^(policy|policies|rules)\b/i
      }.freeze


      # Attempts to fetch an approved document section.
      #
      # @param source_pointer [String] Stable reference to the document
      # @param section [Symbol] Logical section (e.g. :definitions)
      # @param version [String] Document version identifier
      #
      # @return [String, nil]
      #   nil indicates that no authoritative content is available


      # Main execution entrypoint.
      #
      # Returns:
      #   - Full raw section text if the section can be identified
      #   - nil if the document exists but the section cannot be found
      def fetch_section(source_pointer:, section:, version:, term:)
        document_path = resolve_source_pointer(source_pointer, version)
        return nil unless File.exist?(document_path)

        # ------------------------------------------------------------
        # v0.7.2 — PDF → TEXT CONVERSION
        # ------------------------------------------------------------
        text = extract_text(document_path)
        return nil unless text

        # v0.7.2 — SECTION BOUNDARY EXTRACTION
        section_text = extract_section(text, section)
        return nil unless section_text

        # v0.7.3: Extract individual term definition
        extract_term_definition(section_text, term)
      end

      private
      # Resolves a stable document identifier into a concrete file path.
      #
      # NOTE:
      # - Resolution logic is deterministic
      # - No file parsing occurs here
      def resolve_source_pointer(source_pointer, version)
        File.join(File::SEPARATOR, "docs", "#{source_pointer}-#{version}.pdf")
      end

    # Converts a PDF document into plain text deterministically.
      #
      # Uses an external tool (pdftotext) and returns the raw text output.
      # No interpretation or cleanup is applied.
      # v0.7.2 — PDF → TEXT
      def extract_text(document_path)
        output = `pdftotext "#{document_path}" -`
        output.strip.empty? ? nil : output
      rescue
        nil
      end

      # Extracts a full document section based on a declared header.
      #
      # Strategy:
      #   1. Split document text into blocks (paragraphs)
      #   2. Locate the block whose first line matches the section header
      #   3. Collect that block and all following blocks
      #   4. Stop when another known section header is encountered
      #   v0.7.2 — SECTION BOUNDARY EXTRACTION
      def extract_section(text, section)
        header_pattern = SECTION_HEADERS[section]
        return nil unless header_pattern

        blocks = text.split(/\n{2,}/)

        start_index = blocks.find_index do |block|
          first_line = block.lines.first&.strip
          first_line&.match?(header_pattern)
        end

        return nil if start_index.nil?

        collected = []

        blocks[start_index..].each do |block|
          first_line = block.lines.first&.strip

          if collected.any? &&
             SECTION_HEADERS.values.any? { |p| first_line&.match?(p) }
            break
          end

          collected << block
        end

        collected.join("\n\n")
      end

      # Extracts a single authoritative definition for a term
      # from within a previously extracted section.
      #
      # Strategy:
      #   - Identify the term name as an uppercase header
      #   - Collect all subsequent lines until another term header appears
      #

      # ============================================================
      # v0.7.3 — TERM-LEVEL GROUNDED EXTRACTION
      # ============================================================
      def extract_term_definition(section_text, term)
        lines = section_text.lines.map(&:rstrip)

        normalized_term = Regexp.escape(term.strip)
        header_regex = /^#{normalized_term}\b/i

        start_index = lines.find_index do |line|
          line.strip.match?(header_regex)
        end

        return nil if start_index.nil?

        collected = []

        lines[(start_index + 1)..].each do |line|
          # Stop when we hit another term header (uppercase structural boundary)
          break if line.strip.match?(/^[A-Z\s]{3,}$/)

          collected << line
        end

        definition = collected.join("\n").strip
        definition.empty? ? nil : definition
      end
    end
  end
end

