# ============================================================
# ReconciliationLifecycleMap
#
# Introduced as reference in: v0.10
#
# Purpose:
# - Provide an explicit, auditable lifecycle flow
# - Enable future reasoning (v1.x) without inference
#
# IMPORTANT:
# - This class is READ‑ONLY
# - No business logic should mutate lifecycle order
# ============================================================
module Engine
  module Lifecycle
    class ReconciliationLifecycleMap
      FLOW = [
        "NEW",
        "READY",
        "PROCESSING",
        "PARSED",
        "TRAN RECONCILING",
        "RECONCILING",
        "PARTIAL RECONCILED",
        "FULL RECONCILED"
      ].freeze

      def self.next_stage(current)
        index = FLOW.index(current)
        return nil unless index
        FLOW[index + 1]
      end

      def self.terminal?(status)
        status == "FULL RECONCILED"
      end
    end
  end
end