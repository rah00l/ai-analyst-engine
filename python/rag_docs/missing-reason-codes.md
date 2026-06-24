# Missing Reason Codes

## Commission Mismatch

A Commission Mismatch occurs when the system finds a matching transaction in the database (based on transaction ID and other identifiers), but the commission amount in the payment file differs from what is recorded in our system. This can happen when the affiliate network adjusts the commission after the original transaction was reported — for example, due to a partial return, a revised commission rate, or a currency conversion difference. When the payment file is reconciled, these transactions are reconciled at the new amount from the payment file, not the original amount in our database. The difference is recorded as an adjustment.

## Transaction Not Found

Transaction Not Found means the system could not locate any matching record in the database for a transaction listed in the payment file. The network claims they paid us for this transaction, but we have no record of it ever being reported to us. This can happen when a transaction was reported outside our normal tracking window, when there was a data synchronization gap between the network and our system, or when the transaction was recorded under a different identifier. When the payment file is reconciled, the system creates a new transaction record to match the payment file entry, so the payment can still be accounted for.

## Aggregator Transaction ID Not Found

This reason appears when the system found a potential match based on some transaction details (such as click ID or transaction date), but the aggregator transaction ID in the payment file does not match the aggregator transaction ID in our database. This is a weaker mismatch than Transaction Not Found — there is a likely candidate record, but the primary identifier does not align. This can indicate that the network reissued the transaction under a new ID, or that there was a data entry discrepancy on the network side. These transactions are classified as unmatched during reconciliation and are not reconciled against an existing record.

## Aggregator Mismatch

An Aggregator Mismatch occurs when the transaction in the payment file references an affiliate network (aggregator) that does not match the expected aggregator for the merchant or region being reconciled. This can happen when a merchant is associated with multiple aggregators across different regions, or when network acquisitions cause transaction IDs to appear under a new parent network. If the transaction is already fully processed under a different aggregator, it may show as "All transactions with AggTxID already closed." These transactions are classified as unmatched during reconciliation.

## Invalid Date

The Invalid Date reason appears when the transaction date in the payment file is either missing entirely, contains an unrecognizable format, or falls outside any reasonable processing window. The system cannot match a transaction without a valid date because date is one of the key matching criteria used alongside transaction ID and click ID. Common causes include date formatting differences between affiliate networks (some use MM/DD/YYYY, others use YYYY-MM-DD, and some include timezone information that our parser does not expect). These transactions remain unmatched during reconciliation.

## Invalid Sale Value

Invalid Sale appears when the sale amount field in the payment file is empty, contains non-numeric characters, or is otherwise in a format the system cannot interpret as a currency value. Since the sale amount is needed to verify the transaction and calculate commissions, the system cannot process the transaction without a valid sale value. This is typically a data quality issue originating from the affiliate network's payment file generation process. These transactions remain unmatched during reconciliation.

## Invalid Commission Value

Invalid Commission appears when the commission amount in the payment file is zero, empty, or contains non-numeric characters. The system does not process transactions with zero or invalid commission values because there is no payment to reconcile — if the network reports zero commission, there is effectively nothing to match or close. These transactions remain unmatched during reconciliation. If a legitimate transaction genuinely has zero commission (which is rare), it would need to be handled manually outside the standard reconciliation process.

## Transaction Already Closed

Transaction Already Closed means the system found a matching record in the database, but that record has already been marked as closed by a previous reconciliation. This is not actually a problem — it simply means this transaction was already paid and settled in an earlier payment cycle, and the current payment file is referencing it again (possibly as a duplicate or as part of a cumulative payment report). In the current system, these transactions appear in the Closed bucket on the Display Screen rather than in the Missing bucket, to prevent unnecessary investigation.

## Unknown Reason

The Unknown reason appears when the system was unable to determine why a transaction could not be matched. This is a catch-all category for situations that do not fit any of the other defined reason codes. It may indicate an unexpected data format, a system processing error, or an edge case that the matching logic was not designed to handle. These transactions remain unmatched during reconciliation and may require manual investigation by the support team to determine the root cause.
