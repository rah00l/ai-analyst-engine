# Reconcile Buttons

## TRAN RECONCILE Purpose

The TRAN RECONCILE button allows the accounting team to reconcile only the transaction portion of a payment file without settling tenancy fees. This is used when matched transactions need to be closed promptly — for example, to unblock partner commission payments — but tenancy fees cannot be settled yet because campaign mappings are still pending, campaign ADV IDs have not been created in the system, or the tenancy team needs more time to verify the correct mapping. Clicking TRAN RECONCILE moves the file to TRAN RECONCILING status, and once processing completes, the file reaches PARTIAL RECONCILED. The tenancy portion remains open for later settlement.

## FULL RECONCILE Purpose

The FULL RECONCILE button (also called simply RECONCILE on some screens) initiates a complete reconciliation of the payment file — including all matched transactions, all settled tenancy fees, any VAT amounts, and any unmatched or bonus amounts. This button is only enabled when all tenancy fees have been properly mapped to campaigns and the total unresolved amount at the top of the Tenancy Settlement Screen equals zero. If there are still unmapped tenancy fees or if the amounts do not balance, the button remains disabled. Once clicked, the file moves through RECONCILING to FULL RECONCILED status.

## When To Use Which Button

The decision between TRAN RECONCILE and FULL RECONCILE depends on whether tenancy settlement is ready. If the payment file contains no tenancy fees at all, FULL RECONCILE is the correct choice — there is nothing to hold back. If the payment file contains tenancy fees and all campaigns are already mapped and amounts balanced, FULL RECONCILE is again the correct choice. TRAN RECONCILE is specifically for the situation where transactions are ready but tenancies are not — it is a deliberate partial-completion mechanism, not a shortcut or workaround. Using TRAN RECONCILE when FULL RECONCILE is available would leave unnecessary pending work.

## What Happens During Transaction Reconciliation

When TRAN RECONCILE or FULL RECONCILE is triggered, the backend processes all matched transactions by performing several database operations. A new record is added to the aggregator_check table representing this deposit. For each matched transaction, a record is inserted into tranx_reconcile linking the transaction to this deposit. The matched records in tranx_raw are updated to set their closed flag to 1, indicating they have been paid and settled. Partner commission amounts are recorded, and the system begins calculating each partner's share based on the agreed revenue-sharing ratios. For FULL RECONCILE, tenancy payments are additionally recorded against their respective advertising campaigns.

## Pending Queue And Weekly Reminders

Payment files that have been partially reconciled (transactions done, tenancy pending) appear with PARTIAL RECONCILED status on the Payment File Upload screen. The LOAD button next to these files takes the accounting team directly to the Tenancy Settlement Screen where they can complete the remaining tenancy mappings. To prevent partially reconciled files from being forgotten, the system sends weekly reminder emails to designated process owners, listing all files that remain in PARTIAL RECONCILED status and need tenancy settlement attention. This ensures tenancy fees do not remain unresolved indefinitely.
