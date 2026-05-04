# frozen_string_literal: true

# Represents the outcome of a knowledge eligibility decision.
#
# This object is intentionally explicit:
# Every decision is either ALLOWED or DENIED,
# with a concrete reason that can be audited.
#
# Phase: v0.6.1
# Responsibility: Decision result only.

module Engine
  module Eligibility
    class KnowledgeEligibilityResult
      attr_reader :allowed, :reason

      def initialize(allowed:, reason:)
        @allowed = allowed
        @reason  = reason
      end

      def allowed?
        allowed == true
      end
    end
  end
end