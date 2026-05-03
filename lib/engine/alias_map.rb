 module Engine
# frozen_string_literal: true

# Explicit alias → canonical term mappings.
# This map is intentionally conservative.
#
# If a phrase is not listed here, it MUST NOT be resolved.
# Ambiguity always results in NOT_DEFINED.

ALIAS_MAP = {
  # ------------------------
  # PARSED / PARSING
  # ------------------------
  "parsing" => "PARSED",
  "parse" => "PARSED",
  "parsed" => "PARSED",
  "file parsed" => "PARSED",
  "file parsing completed" => "PARSED",

  # ------------------------
  # NEW / READY / PROCESSING
  # ------------------------
  "new" => "NEW",
  "file uploaded" => "NEW",

  "ready" => "READY",
  "ready for parsing" => "READY",

  "processing" => "PROCESSING",
  "file processing" => "PROCESSING",
  "processing file" => "PROCESSING",

  # ------------------------
  # PARTIAL / FULL RECONCILIATION
  # ------------------------
  "partial reconciliation" => "PARTIAL RECONCILED",
  "partially reconciled" => "PARTIAL RECONCILED",
  "partial reconciled" => "PARTIAL RECONCILED",
  "file partially reconciled" => "PARTIAL RECONCILED",

  "fully reconciled" => "FULL RECONCILED",
  "full reconciliation" => "FULL RECONCILED",
  "full reconciled" => "FULL RECONCILED",

  "reconciled" => "RECONCILED",
  "file reconciled" => "RECONCILED",

  # ------------------------
  # TRANSACTION RECONCILING
  # ------------------------
  "tran reconciling" => "TRAN RECONCILING",
  "transaction reconciling" => "TRAN RECONCILING",
  "ready for transaction reconciliation" => "TRAN RECONCILING",

  "processing tran reconciling" => "PROCESSING TRAN RECONCILING",
  "transaction reconciliation in progress" => "PROCESSING TRAN RECONCILING",

  # ------------------------
  # RECONCILING
  # ------------------------
  "reconciling" => "RECONCILING",
  "ready for reconciliation" => "RECONCILING",

  "processing reconciling" => "PROCESSING RECONCILING",
  "reconciliation in progress" => "PROCESSING RECONCILING",

  # ------------------------
  # MAPPING ERRORS
  # ------------------------
  "mapping error payment id not found" => "MAPPING ERROR - Payment ID Not Found",
  "mapping error payment id" => "MAPPING ERROR - Payment ID Not Found",
  "payment id not found" => "MAPPING ERROR - Payment ID Not Found",

  "mapping error data format issue" => "MAPPING ERROR - Data Format Issue",
  "mapping error format" => "MAPPING ERROR - Data Format Issue",
  "data format issue" => "MAPPING ERROR - Data Format Issue",

  # ------------------------
  # PARSING & RECONCILING ERRORS
  # ------------------------
  "parsing error" => "PARSING ERROR - Contact Support",
  "parsing error contact support" => "PARSING ERROR - Contact Support",

  "reconciling error" => "RECONCILING ERROR - Contact Support",
  "reconciliation error" => "RECONCILING ERROR - Contact Support",
  "reconciling error contact support" => "RECONCILING ERROR - Contact Support"
}.freeze