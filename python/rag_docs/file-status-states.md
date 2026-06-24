# File Status States

## NEW

A payment file enters the NEW state immediately after it has been uploaded into the system. At this point, no processing has occurred — the file has simply been received and registered. The system has recorded the file's metadata (region, affiliate network, deposit date, deposit amount, network payment ID) but has not yet attempted to read, parse, or validate the file's contents. NEW is the very first lifecycle state, and every payment file begins here. No reconciliation activity of any kind has taken place at this stage. The file will remain in NEW until a user or automated process initiates parsing.

## READY

A payment file moves to READY after initial validation checks have passed and the file is queued for processing. At this stage, the system has confirmed that mandatory fields (aggregator, deposit date, deposit amount) are present, that the network payment ID and filename are unique (no duplicates), and that the file format is one of the supported types (XML, JSON, XLS, XLSX, or CSV). The file has not yet been parsed or matched against any database records — READY simply means "validated and waiting in the processing queue." A backend job picks up READY files periodically for parsing.

## PROCESSING

PROCESSING indicates that the system is actively working on the payment file. During this state, the backend is reading the file contents, applying the column-mapping rules specific to the affiliate network, and extracting individual transaction records. The file should not be modified or re-uploaded while in PROCESSING state. This is a transient, system-owned state — it will automatically transition to either PARSED (if processing succeeds) or an error state such as MAPPING ERROR or PARSING ERROR (if something goes wrong during extraction).

## PARSED

A payment file reaches PARSED status when transaction data has been successfully extracted and structured from the raw file. At this point, each transaction from the file has been matched (or attempted to be matched) against existing records in the database. The system has classified every transaction into one of several buckets: paid transactions that matched successfully, missing transactions that could not be found or had data discrepancies, declined transactions, and already-closed transactions. Parsing also identifies any tenancy fee records and bonus amounts within the file. PARSED is the gateway to reconciliation — the file is now eligible to proceed, but no reconciliation outcomes have been finalized yet. Users can review the parsed results on the Display Screen before deciding to reconcile.

## TRAN RECONCILING

TRAN RECONCILING means the system is in the process of reconciling only the transaction portion of a payment file, without settling tenancy fees. This state is entered when a user clicks the TRAN RECONCILE button, which is used when the accounting team wants to close out matched transactions immediately but is not yet ready to handle tenancy settlements (perhaps because campaign mappings are still being confirmed or because tenancy-related approvals are pending). During TRAN RECONCILING, the system is updating database records — marking matched transactions as closed, inserting reconciliation records, and calculating partner commission amounts. This is an automated backend process and typically completes within minutes.

## RECONCILING

RECONCILING indicates that the system is performing a full reconciliation of the payment file — this includes both transaction matching and tenancy fee settlement. This state is entered when a user clicks the FULL RECONCILE button, which is only enabled after all tenancy fees have been mapped to campaigns and the total unmatched amount has been resolved to zero. During RECONCILING, the system processes everything: closing matched transactions, recording tenancy payments against their advertising campaigns, handling any VAT or unmatched bonus amounts, and updating all relevant database tables. Like TRAN RECONCILING, this is an automated backend process.

## PARTIAL RECONCILED

A payment file shows PARTIAL RECONCILED when the transaction portion has been successfully reconciled but tenancy fees remain unsettled. This is the expected outcome after a TRAN RECONCILE operation. The file is in a deliberate holding state — it is not stuck or errored, but it cannot proceed to full reconciliation until the outstanding tenancy items are addressed. Typical reasons tenancy remains unresolved include: the campaign (ADV ID) has not yet been created in the system, the paid amount does not match any existing campaign exactly, or the naming convention in the payment file does not match the system's campaign records. The accounting team must return to the Tenancy Settlement Screen, map the remaining tenancy fees to the correct campaigns, and then trigger a FULL RECONCILE to complete the process. Weekly reminder emails are sent for files that remain in PARTIAL RECONCILED state.

## FULL RECONCILED

FULL RECONCILED is the terminal state indicating that all processing for this payment file is complete. Every matched transaction has been closed in the database, all tenancy fees have been settled against their respective campaigns, any VAT or unmatched amounts have been recorded, and partner commission calculations have been triggered. No further action is required on this file. The reconciliation summary and detailed transaction reports are available for download. This state is permanent — once a file reaches FULL RECONCILED, it does not transition to any other state.

## MAPPING ERROR

A MAPPING ERROR occurs during the PROCESSING stage when the system cannot correctly interpret the payment file's structure according to the expected column mappings for that affiliate network. Common causes include: the file format does not match what is configured for this network (for example, receiving a CSV when the system expects XLS), column headers or data positions have changed from what was previously mapped, or the network payment ID recorded in the system does not match any payment ID found within the file itself. When a MAPPING ERROR occurs, the file cannot proceed — it must be removed from the system, the issue investigated and corrected, and the file re-uploaded. The specific error description (shown alongside the MAPPING ERROR status) indicates which particular mapping rule failed.

## PARSING ERROR

A PARSING ERROR indicates that an unexpected system-level failure occurred during file processing — something beyond a simple mapping mismatch. This could be a timeout, a malformed file that crashes the parser, an encoding issue, or an internal system exception. Unlike MAPPING ERROR (which points to a data/configuration problem), PARSING ERROR typically requires the support team to investigate the root cause. The file should be removed from the Payment File Upload screen, and the support team should be contacted. After the issue is diagnosed and resolved, the file can be re-uploaded for another processing attempt.
