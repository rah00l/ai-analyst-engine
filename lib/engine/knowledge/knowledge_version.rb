# frozen_string_literal: true

# Represents versioning metadata for a knowledge source.
#
# This class does NOT compare versions or select the latest.
# It only declares which versions exist and which are active.
#
# Version awareness is essential for auditability and
# future explanations such as "this rule changed in version X".
#
# Phase: v0.6.0
# Responsibility: Temporal governance ONLY.
module Engine
  module Knowledge
    class KnowledgeVersion
      attr_reader :version_id, :effective_from, :effective_to, :status

      def initialize(version_id:, effective_from:, effective_to: nil, status: :active)
        @version_id     = version_id
        @effective_from = effective_from
        @effective_to   = effective_to
        @status         = status # :active or :deprecated
      end

      def active?
        status == :active
      end
    end
  end
end