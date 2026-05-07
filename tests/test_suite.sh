#!/bin/bash

# ============================================================
# AI Analyst Engine — Test Suite (Session‑Correct)
# ============================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ENGINE_URL="http://localhost:4567/analyze"
TESTS_PASSED=0
TESTS_FAILED=0

echo "================================================"
echo "  AI Analyst Engine - Test Suite v1.0.0"
echo "================================================"
echo ""

# ------------------------------------------------------------
# Helper: run single request + assertion
# ------------------------------------------------------------
run_test() {
  local test_name=$1
  local question=$2
  local session_id=$3
  local expected_status=$4

  echo -n "• $test_name ... "

  response=$(curl -s -X POST "$ENGINE_URL" \
    -H "Content-Type: application/json" \
    -d "{\"question\":\"$question\",\"session_id\":\"$session_id\"}")

  # Determine SUCCESS vs NOT_DEFINED vs ERROR
  actual_status=$(echo "$response" | jq -r '
    if (.result.result | type) == "object" and .result.result.status then
      .result.result.status
    elif (.result.result | type) == "string" then
      "SUCCESS"
    elif .result.status then
      .result.status
    else
      "UNKNOWN"
    end
  ' 2>/dev/null)

  if [[ "$actual_status" == "$expected_status" ]]; then
    echo -e "${GREEN}PASS${NC}"
    ((TESTS_PASSED++))
  else
    echo -e "${RED}FAIL${NC}"
    echo "    Expected: $expected_status"
    echo "    Got:      $actual_status"
    echo "    Response: $response"
    ((TESTS_FAILED++))
  fi
}

# ============================================================
# CATEGORY 1 — Definition & Status Meaning (Stateless)
# ============================================================
echo ""
echo -e "${YELLOW}CATEGORY 1 — Definitions (Stateless)${NC}"
echo "------------------------------------------------"

run_test "NEW definition" \
  "What does NEW mean?" \
  "stateless_1" \
  "SUCCESS"

run_test "READY definition" \
  "What does READY mean?" \
  "stateless_2" \
  "SUCCESS"

run_test "PROCESSING definition" \
  "What does PROCESSING mean?" \
  "stateless_3" \
  "SUCCESS"

run_test "PARSED definition" \
  "What does PARSED mean?" \
  "stateless_4" \
  "SUCCESS"

run_test "PARTIAL RECONCILED definition" \
  "What does PARTIAL RECONCILED mean?" \
  "stateless_5" \
  "SUCCESS"

run_test "FULL RECONCILED definition" \
  "What does FULL RECONCILED mean?" \
  "stateless_6" \
  "SUCCESS"

run_test "MAPPING ERROR definition" \
  "What does MAPPING ERROR – Payment ID Not Found mean?" \
  "stateless_7" \
  "SUCCESS"

# ============================================================
# CATEGORY 2 — Alias Robustness (Stateless)
# ============================================================
echo ""
echo -e "${YELLOW}CATEGORY 2 — Alias Robustness${NC}"
echo "------------------------------------------------"

run_test "Alias: lowercase mapping error" \
  "What does mapping error payment id not found mean?" \
  "alias_1" \
  "SUCCESS"

run_test "Alias: payment id not found" \
  "What does payment id not found mean?" \
  "alias_2" \
  "SUCCESS"

# ============================================================
# CATEGORY 3 — Follow‑up Chains (Session‑Scoped)
# ============================================================
echo ""
echo -e "${YELLOW}CATEGORY 3 — Follow‑Up Chains (Session Required)${NC}"
echo "------------------------------------------------"

SESSION_FOLLOWUP_1="followup_mapping_error"

run_test "Chain start: mapping error definition" \
  "What does MAPPING ERROR – Payment ID Not Found mean?" \
  "$SESSION_FOLLOWUP_1" \
  "SUCCESS"

run_test "Follow‑up: blocking?" \
  "Does this block reconciliation?" \
  "$SESSION_FOLLOWUP_1" \
  "SUCCESS"

run_test "Follow‑up: ownership?" \
  "Who is responsible for resolving this?" \
  "$SESSION_FOLLOWUP_1" \
  "SUCCESS"

run_test "Follow‑up: consequence?" \
  "What happens if nothing is done?" \
  "$SESSION_FOLLOWUP_1" \
  "SUCCESS"

# ============================================================
# CATEGORY 4 — Invalid Follow‑ups (Must Fail)
# ============================================================
echo ""
echo -e "${YELLOW}CATEGORY 4 — Invalid Follow‑Ups (No Context)${NC}"
echo "------------------------------------------------"

run_test "Invalid follow‑up without context" \
  "Does this block reconciliation?" \
  "no_context_1" \
  "NOT_DEFINED"

run_test "Invalid ownership follow‑up" \
  "Who is responsible for this?" \
  "no_context_2" \
  "NOT_DEFINED"

# ============================================================
# CATEGORY 5 — Lifecycle Reasoning (Stateless Explicit)
# ============================================================
echo ""
echo -e "${YELLOW}CATEGORY 5 — Lifecycle Reasoning${NC}"
echo "------------------------------------------------"

run_test "Lifecycle: next after PARSED" \
  "What stage comes after PARSED?" \
  "lifecycle_1" \
  "NOT_DEFINED"

run_test "Lifecycle: terminal check" \
  "Is FULL RECONCILED a terminal state?" \
  "lifecycle_2" \
  "NOT_DEFINED"


# ============================================================
# CATEGORY 6 — Boundary Enforcement (Should Refuse)
# ============================================================
echo ""
echo -e "${YELLOW}CATEGORY 6 — Boundary Enforcement${NC}"
echo "------------------------------------------------"

run_test "Boundary: how to fix" \
  "How do I fix this error?" \
  "boundary_1" \
  "NOT_DEFINED"

run_test "Boundary: what should I do next" \
  "What should I do next?" \
  "boundary_2" \
  "NOT_DEFINED"

run_test "Boundary: UI action" \
  "Which button should I click?" \
  "boundary_3" \
  "NOT_DEFINED"

# ============================================================
# CATEGORY 7 — Comparative / What‑If (Explicitly Unsupported)
# ============================================================
echo ""
echo -e "${YELLOW}CATEGORY 7 — Comparative & What‑If (Unsupported)${NC}"
echo "------------------------------------------------"

run_test "Comparative reasoning" \
  "What is the difference between PARTIAL RECONCILED and FULL RECONCILED?" \
  "compare_1" \
  "NOT_DEFINED"

run_test "What‑if reasoning" \
  "What happens if reconciliation never completes?" \
  "whatif_1" \
  "NOT_DEFINED"

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo "================================================"
echo "  TEST RESULTS SUMMARY"
echo "================================================"
echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
echo "  Total: $((TESTS_PASSED + TESTS_FAILED))"
echo "================================================"

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ All tests passed.${NC}"
  exit 0
else
  echo -e "${RED}❌ Some tests failed.${NC}"
  exit 1
fi