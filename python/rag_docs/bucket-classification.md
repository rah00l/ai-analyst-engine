# Bucket Classification

## Paid Bucket

The Paid bucket contains transactions from the payment file that were successfully matched against existing records in the database. A transaction lands in Paid when the system finds a corresponding record with a matching aggregator transaction ID, click ID, and transaction date, and the commission amounts are within acceptable tolerance. These transactions are ready to be reconciled — meaning they can be marked as closed in the database, which triggers partner commission calculations. The Paid bucket represents the ideal outcome of parsing: the network said they paid us for this transaction, and our records confirm we expected that payment.

## Declined Bucket

The Declined bucket holds transactions that the affiliate network has explicitly marked as declined in their payment file. A declined transaction means the network reversed or rejected a previously reported sale — the consumer may have returned the product, cancelled the order, or the transaction was flagged as fraudulent. Currently, Commission Junction is the only affiliate network that includes declined transaction data in their payment files. Declined transactions are informational — they are not reconciled against our database records, but they are tracked for accounting visibility and to explain discrepancies between expected and actual payment amounts.

## Missing Bucket

The Missing bucket contains transactions from the payment file that the system could not match with any existing database record, or where the match was found but key data did not align. Each missing transaction is tagged with a specific reason code explaining why the match failed — for example, Transaction Not Found, Commission Mismatch, Aggregator Transaction ID Not Found, Invalid Sale, or Invalid Date. The Missing bucket is where most human investigation effort is focused during reconciliation. Users can review the specific reasons on the Missing Screen, and when reconciliation proceeds, missing transactions are handled differently depending on their reason — some create new records, others remain as unmatched entries.

## Closed Bucket

The Closed bucket contains transactions from the payment file that matched records in the database, but those records were already marked as closed from a previous reconciliation. This means the transaction was already paid and settled in an earlier payment cycle. In the legacy system, these appeared under the Missing bucket, which caused confusion — analysts would investigate them thinking they were genuinely unmatched, only to discover they were already handled. In the current system, Closed transactions are separated out on the Display Screen specifically to prevent this wasted investigation effort. They are informational only and do not require any action.

## Display Screen Overview

After a payment file has been parsed, the Display Screen shows a merchant-by-merchant summary of how all transactions were classified across the buckets. For each merchant, the screen shows the total sales and commission amounts broken down by Paid, Declined, Missing, and Closed status. Below the merchant table, the screen also shows the total Tenancy Fee amount, any Unmatched or Bonus amount, and the overall Deposit Amount. This gives the accounting team a single high-level view of the payment file's health before deciding whether to proceed with reconciliation. From the Display Screen, users can navigate to the Missing Screen for detailed investigation or proceed directly to reconciliation.
