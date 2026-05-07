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
# lib/engine/lifecycle/reconciliation_life_cycle_map.rb
require "yaml"

module Engine
  module Lifecycle
    class ReconciliationLifecycleMap
      LIFECYCLE_PATH = File.expand_path(
        "../../../../resources/accounting/lifecycle.yml",
        __FILE__
      )

      config = YAML.load_file(LIFECYCLE_PATH)
      FLOW = config.fetch("flow").freeze
      TERMINAL = config.fetch("terminal").freeze

      def self.next_stage(current)
        index = FLOW.index(current)
        return nil unless index
        FLOW[index + 1]
      end

      def self.terminal?(status)
        status == TERMINAL
      end
    end
  end
end