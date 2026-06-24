# Tenancy Settlement Rules

## What Are Tenancy Fees

Tenancy fees are fixed payments that merchants pay to participate in advertising campaigns or promotional placements on partner platforms. Unlike transaction-based commissions (which are calculated per sale), tenancy fees are flat amounts agreed upon in advance — for example, a merchant might pay a fixed fee for a homepage banner placement for one month. Tenancy fees appear in payment files alongside regular transaction commissions but are handled separately during reconciliation because they must be matched against specific advertising campaigns (ADV IDs) in the system rather than against individual consumer transactions.

## Tenancy Fee Paid In Full With Matching Campaign

When a tenancy fee in the payment file exactly matches an existing campaign (ADV ID) in the system — both in amount and naming convention — the system automatically maps it on the Tenancy Settlement Screen. The accounting team simply needs to verify the auto-populated mapping is correct and proceed with reconciliation. This is the simplest and most common tenancy scenario. The campaign status changes from NEW to PAID after reconciliation completes.

## Tenancy Fee Paid In Full But Campaign Not In Payment File

Sometimes a tenancy fee payment is received but the specific campaign name does not appear in the payment file itself — only the amount is present, without a clear label linking it to a campaign. In this case, the accounting team must manually identify which campaign the payment belongs to using the Tenancy Settlement Screen dropdown. The dropdown shows all campaigns with NEW status, sorted alphabetically by merchant name, ADV ID, and campaign name. The team selects the correct campaign, enters the paid amount, and proceeds with reconciliation.

## Tenancy Fee Paid In Full But No Matching Naming Convention

When the payment file contains a tenancy fee with a campaign reference that does not match the naming convention used in our system — for example, the network uses an abbreviated or differently formatted campaign name — the system cannot auto-map it. The accounting team must manually select the correct campaign from the Tenancy Settlement Screen dropdown based on their knowledge of which campaign the payment relates to. This requires familiarity with the merchant's active campaigns and the network's naming patterns.

## Tenancy Fee Paid But Campaign Not Created Yet

If a tenancy fee payment arrives before the corresponding campaign (ADV ID) has been created in the system, there is nothing to map it to. In this situation, the accounting team should use the TRAN RECONCILE button to reconcile only the transaction portion of the payment file, leaving the tenancy fees unsettled. The file will move to PARTIAL RECONCILED status. Once the campaign is created in the system by the client relationship team, the accounting team can return to the Tenancy Settlement Screen and complete the tenancy mapping, then trigger FULL RECONCILE.

## Tenancy Fee Paid In Multiple Line Items

Sometimes a merchant's tenancy fee arrives split across multiple line items in the same payment file rather than as a single lump sum. On the Tenancy Settlement Screen, these multiple lines are consolidated and shown as one entry with the summed total amount — provided the campaign name in the payment file is the same across all line items. The team needs to verify the total matches the expected campaign amount and adjust the mapping on the settlement screen if necessary.

## Tenancy Fee Partial Payment

When only a portion of the expected tenancy fee is received in a payment cycle, the system handles it as a partial payment. During reconciliation, the existing campaign (ADV ID) status changes from NEW to READY with the received amount recorded. The system automatically triggers an email notification to the client relationship team, informing them that a partial payment was received and requesting them to create a new ADV ID for the outstanding balance amount. The accounting team must adjust the tenancy on the Tenancy Settlement Screen to reflect the partial payment before proceeding with reconciliation.

## Tenancy Type Selection

On the Tenancy Settlement Screen, each tenancy entry requires a Tenancy Type selection — either Tenancy or BMG (Bulk Media Guarantee). This selection determines the commission split ratio that applies when the tenancy fee is distributed between partners. The system displays the configured split ratio based on the selected type. If the wrong type is initially selected, it can be changed before saving — but the split ratio updates automatically when the type changes. Both the type and the split ratio must be confirmed before the FULL RECONCILE button becomes active.
