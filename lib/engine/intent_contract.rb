# frozen_string_literal: true

# Canonical Intent Contract
#
# This struct represents a fully-resolved, execution-safe
# request that can be passed to the grounding layer.
#
# No defaults. No inference. All fields are explicit.
module Engine
  Intent = Struct.new(
    :category,   # :definition (only supported category in v0.8)
    :source,     # e.g. "RECONCILIATION_HANDBOOK"
    :version,    # e.g. "v2.1"
    :section,    # e.g. :definitions
    :term,       # Canonical document term (e.g. "PARSED")
    :confidence, # :high (reserved for future UX)
    keyword_init: true
  )
end