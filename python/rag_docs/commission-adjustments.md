# Commission Adjustments

## Why Commission Amounts Change

During reconciliation, it is common for the final commission amount to differ from the initial commission amount that was originally reported when the transaction occurred. This is not an error — it reflects legitimate adjustments that happen between the time a transaction is first reported and the time the network actually sends payment. Understanding why these differences occur is important for accurate accounting and for explaining apparent discrepancies to partners or internal stakeholders.

## Partial Returns And Order Modifications

The most common reason for a commission change is that the consumer modified their order after the original transaction was reported. If a consumer returns part of their purchase, the network adjusts the commission downward to reflect the reduced sale amount. For example, if a consumer originally bought items worth five hundred dollars but returned one hundred dollars worth of products, the commission in the payment file will be based on the four hundred dollar net sale, not the original five hundred. The difference between initial and final commission reflects this adjustment.

## Network Commission Rate Adjustments

Occasionally, an affiliate network revises the commission rate for a merchant after transactions have already been reported at the old rate. This can happen when contract terms are renegotiated, when promotional commission rates expire, or when the network corrects a configuration error. The payment file will contain the revised commission amounts, which may be higher or lower than what our system originally recorded. During reconciliation, the system updates to the payment file amounts, and the difference is recorded as an adjustment.

## Currency Conversion Differences

For international transactions, commission amounts are sometimes reported in one currency but paid in another. Small differences between the exchange rate at the time of reporting and the exchange rate at the time of payment can cause the final commission to differ from the initial amount. These differences are typically small (fractions of a percent) but appear across many transactions and can add up to a noticeable total discrepancy in the reconciliation summary.

## Bonus Amounts

Some payment files include bonus payments — amounts that the network pays above and beyond the standard transaction commissions. These bonuses might represent performance incentives, promotional bonuses, or tenancy-related payments that the network bundles into the same payment file. The bonus amount is calculated as the difference between the total deposit amount and the sum of all transaction commissions plus tenancy fees plus VAT. If the deposit is larger than the sum of identifiable line items, the remainder is classified as a bonus. If no bonus exists, this value is zero.

## Unmatched Amount Calculation

The unmatched amount on the Tenancy Settlement Screen represents the portion of the deposit that could not be attributed to any matched transaction, settled tenancy, or VAT. It includes commissions from transactions with certain reason codes — specifically, transactions classified as Already Closed, Aggregator Transaction ID Not Found, Aggregator Mismatch, Invalid Sale, or Invalid Date. These are transactions the system could not reconcile against existing records, so their commission amounts remain unattributed. The unmatched amount field is editable, allowing the accounting team to adjust it manually if they can attribute some of the unmatched funds through offline investigation.

## VAT Handling

Some affiliate networks include VAT (Value Added Tax) amounts in their payment files, separate from transaction commissions and tenancy fees. The VAT amount is displayed on the Tenancy Settlement Screen and is reconciled as part of the FULL RECONCILE process. The VAT field is editable to allow the accounting team to enter or adjust the VAT amount if the payment file does not break it out explicitly. VAT is recorded separately in the reconciliation records for tax reporting purposes.
