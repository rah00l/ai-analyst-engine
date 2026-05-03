module Engine

# frozen_string_literal: true

# ContextStore
#
# v0.10.0 — Contextual Reuse
#
# PURPOSE:
# Stores the most recent ExplanationContract for safe contextual reuse.
#
# DESIGN CONSTRAINTS:
# - Stores exactly one explanation
# - Read-only access
# - No mutation, inference, or enrichment
# - Cleared on session reset or overwrite

class ContextStore
  def initialize
    @last_explanation = nil
  end

  def store(explanation_contract)
    return unless explanation_contract

    @last_explanation = explanation_contract
  end

  def fetch
    @last_explanation
  end

  def clear
    @last_explanation = nil
  end

  def empty?
    @last_explanation.nil?
  end
end