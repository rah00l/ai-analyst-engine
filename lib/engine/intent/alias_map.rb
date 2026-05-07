 # frozen_string_literal: true

# Explicit alias → canonical term mappings.
# This map is intentionally conservative.
#
# If a phrase is not listed here, it MUST NOT be resolved.
# Ambiguity always results in NOT_DEFINED.
# lib/engine/intent/alias_map.rb — replace entire ALIAS_MAP hash
require "yaml"

module Engine
  module Intent
    CONCEPTS_PATH = File.expand_path(
      "../../../../resources/accounting/concepts.yml",
      __FILE__
    )

    ALIAS_MAP = YAML.load_file(CONCEPTS_PATH)
                .fetch("aliases")
                .freeze
  end
end
