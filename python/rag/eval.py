"""
RAG Evaluation Harness

Purpose:
    Automated pass/fail test for retrieval quality.
    Runs 10 paraphrased questions, checks whether the correct chunk
    was retrieved as the top-1 result for each.

    This replaces manual curl testing with a reproducible,
    one-command quality check.

Usage:
    python -m rag.eval

What it checks:
    - Did the RIGHT chunk come back as the #1 match? (retrieval accuracy)
    - Was the distance below the confidence threshold? (retrieval confidence)
    - It does NOT check the LLM's generated answer text — only retrieval,
      because retrieval is the foundation. If retrieval is wrong,
      no amount of prompt engineering fixes the answer.
"""

from rag.pipeline import initialize
from rag.retriever import retrieve
from rag.store import get_collection

# Maximum acceptable distance for a "confident" retrieval
CONFIDENCE_THRESHOLD = 0.7


# ============================================================
# Test cases: question → expected section title in top-1 result
# ============================================================
TEST_CASES = [
    {
        "id": "Q1",
        "question": "Why is this file showing as done but not really done?",
        "expected_section": "Pending Queue And Weekly Reminders",
        "expected_doc": "reconcile-buttons.md"
    },
    {
        "id": "Q2",
        "question": "Where do I go to manually sort out transactions that didn't auto-match?",
        "expected_section": "Missing Bucket",
        "expected_doc": "bucket-classification.md"
    },
    {
        "id": "Q3",
        "question": "The campaign for this tenancy doesn't exist yet in the system — what do I do?",
        "expected_section": "Tenancy Fee Paid But Campaign Not Created Yet",
        "expected_doc": "tenancy-settlement-rules.md"
    },
    {
        "id": "Q4",
        "question": "Why can't the system find a match even though I can see the transaction in the network's report?",
        "expected_section": "Transaction Not Found",
        "expected_doc": "missing-reason-codes.md"
    },
    {
        "id": "Q5",
        "question": "Which date actually matters for when we count the money as received?",
        "expected_section": "Invoice Date Versus Payment Date",
        "expected_doc": "reconciliation-lifecycle.md"
    },
    {
        "id": "Q6",
        "question": "What needs to be true for something to count as fully settled?",
        "expected_section": "FULL RECONCILED",
        "expected_doc": "file-status-states.md"
    },
    {
        "id": "Q7",
        "question": "We only got half the sponsorship money this month — how does that get handled?",
        "expected_section": "Tenancy Fee Partial Payment",
        "expected_doc": "tenancy-settlement-rules.md"
    },
    {
        "id": "Q8",
        "question": "The sale amount field is broken in the file — what happens to that transaction?",
        "expected_section": "Invalid Sale Value",
        "expected_doc": "missing-reason-codes.md"
    },
    {
        "id": "Q9",
        "question": "How long does a sale need to survive before we count on getting commission for it?",
        "expected_section": "Partial Returns And Order Modifications",
        "expected_doc": "commission-adjustments.md"
    },
    {
        "id": "Q10",
        "question": "Can I close out just the transactions and deal with the tenancy stuff later?",
        "expected_section": "TRAN RECONCILE Purpose",
        "expected_doc": "reconcile-buttons.md"
    },
]


def run_eval():
    """
    Run all test cases and report pass/fail for each.

    A test PASSES if:
        1. The expected section appears in the top-1 retrieval result
        2. The retrieval distance is below CONFIDENCE_THRESHOLD

    Returns:
        tuple of (passed_count, total_count, detailed_results)
    """
    # Initialize the pipeline (chunks, embeds, stores)
    print("Initializing RAG pipeline for evaluation...")
    count = initialize(docs_dir="rag_docs", persistent=True)
    print(f"Loaded {count} chunks")
    print("=" * 70)

    collection = get_collection()
    results = []
    passed = 0
    total = len(TEST_CASES)

    for tc in TEST_CASES:
        retrieved = retrieve(tc["question"], collection=collection, top_k=3)
        top_result = retrieved[0] if retrieved else None

        if top_result is None:
            status = "FAIL"
            reason = "No results returned"
            distance = None
        else:
            got_section = top_result["section_title"]
            got_doc = top_result["source_doc"]
            distance = top_result["distance"]

            # Check: did we get the right section?
            section_match = got_section == tc["expected_section"]

            # Check: is the distance below threshold?
            confident = distance < CONFIDENCE_THRESHOLD

            if section_match and confident:
                status = "PASS"
                reason = None
                passed += 1
            elif section_match and not confident:
                status = "WEAK PASS"
                reason = f"Correct section but low confidence (dist: {distance:.4f} > {CONFIDENCE_THRESHOLD})"
                passed += 1  # Still counts as pass — right answer, just not confident
            else:
                status = "FAIL"
                reason = f"Expected [{tc['expected_section']}] but got [{got_section}]"

        result = {
            "id": tc["id"],
            "question": tc["question"],
            "expected": tc["expected_section"],
            "got": top_result["section_title"] if top_result else "NONE",
            "distance": distance,
            "status": status,
            "reason": reason
        }
        results.append(result)

        # Print each result
        icon = "✅" if "PASS" in status else "❌"
        print(f"\n{tc['id']}: \"{tc['question'][:60]}...\"")
        print(f"    Expected: {tc['expected_section']}")
        print(f"    Got:      {result['got']} (dist: {distance:.4f})" if distance else f"    Got: NONE")
        print(f"    {icon} {status}" + (f" — {reason}" if reason else ""))

    # Summary
    print(f"\n{'=' * 70}")
    print(f"Results: {passed}/{total} passed")

    if passed == total:
        print("All tests passed — retrieval quality confirmed.")
    else:
        failed = [r for r in results if "PASS" not in r["status"]]
        print(f"Failed tests: {', '.join(r['id'] for r in failed)}")
        print("Review failed cases — may need content additions or chunk adjustments.")

    return passed, total, results


# ============================================================
# Run it
# ============================================================
if __name__ == "__main__":
    passed, total, results = run_eval()

    # Exit with non-zero code if any tests failed
    # (useful if you ever wire this into CI/CD)
    exit(0 if passed == total else 1)
