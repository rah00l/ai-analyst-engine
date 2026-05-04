
# frozen_string_literal: true

# BoundaryResponder
#
# v0.10.0 — Contextual Reuse
#
# PURPOSE:
# Provides a short, neutral message when a question
# is outside the analyzer's responsibility.
module Engine
  module FollowUp
    class BoundaryResponder
      def respond
        "I can explain system states and meanings, but I can’t provide operational or UI guidance."
      end
    end
  end
end
