# Data audit findings

Audited directly from the supplied CSVs in read-only mode. The counts below describe these files and should be rechecked after any reload.

## File profile

| File | Rows | Columns | Blank fields |
|---|---:|---:|---:|
| Inventory | 284,755 | 18 | None |
| Sales | 125,751 | 17 | `Reason of Return` is blank on all 125,751 rows |

Both files contain 2,326 products and 40 stores. They contain 30 anonymized suppliers and one sales channel (`Channel Alpha`). Inventory has one store type, `Retail Storefront`.

## Sales checks

- Date range: 2025-06-01 through 2026-04-24. Sales dates are stored as `DD-MM-YYYY` in the CSV.
- 118,260 rows have `Is Return = 0`; 7,491 have `Is Return = 1` (5.96% of rows). Call this **return-line share**, not a return rate: there is no transaction ID or customer-level denominator.
- Every return row has quantity, sales amount, and COGS below zero; every return quantity is exactly −1. No non-return row has negative quantity, sales, or COGS. There are two zero-quantity and nine zero-sales non-return rows.
- Positive sales: $11,215,681.26; negative return sales: −$733,571.01; net sales: $10,482,110.25.
- Net COGS: $5,847,751.10; derived gross profit: $4,634,359.15; derived gross margin: 44.21%.
- Net quantity: 116,995 units. Sum of `Number of Transactions`: 131,120. This is distinct from 125,751 rows. The file has no transaction ID; avoid describing row count as transaction count.
- Return value magnitude is 6.54% of positive sales. This is a value comparison, not a customer return probability.
- April 2026 ends on April 24 and is partial. Do not compare it as a full month or annualize it.
- Top two categories by net sales are Scholar Footwear Retro Legend ($1,920,958.56) and Scholar Footwear Trailblazer ($1,909,759.99), together about 36.54% of net sales.
- Top five supplier labels account for 88.02% of sales attributed to suppliers. This is concentration of recorded sales, not a supplier scorecard.

## Inventory checks

- Date range: Start Date 2025-06-01 to 2026-04-24. There are 22,701 rows with End Date `9999-12-31`; treat this as an open-ended validity sentinel. There are 34,998 rows with same-day start/end and no end-before-start intervals.
- Composite key `(Start Date, End Date, Supplier, Product No, Store, Sales Channel)` is unique. Product/store/channel date intervals do not overlap.
- Qty on hand is negative in 1,380 rows, zero in 13,869, and positive in the remainder. Negative balances should be reported as negative balances, not silently recoded to zero.
- `Stocks Selling Amount = Qty on hand × Stock Unit Selling Price` for every row.
- `Cost of Stocks` differs from `Qty on hand × Stock Unit Cost Price` by more than $0.011 in 8,402 rows (2.95%); all are zero-on-hand rows and 3,272 differences exceed $1. Do not use recorded stock cost as a trusted inventory valuation without resolution.
- There are 8,022 negative recorded stock costs; 6,625 are zero-on-hand rows, 1,376 negative-on-hand rows, and 21 positive-on-hand rows. Also, 25 unit cost prices are negative.
- Status mix: Full Price 261,899; Markdown Tier 1 12,091; Clearance 3,798; Markdown Tier 2 6,937; Promo 30.

## As-of inventory snapshot

At the last sales date, 2026-04-24, 22,701 inventory rows are active across 1,965 products and all 40 stores. Summed on-hand quantity is 37,187 units and the source's retail stock amount sums to $3,592,535.99. There are 2,784 zero and 321 negative on-hand rows. Recorded stock cost sums to $1,804,169.10, but 1,466 active rows fail the cost reconciliation, so do not headline this as validated inventory cost. The as-of assortment has 1,965 of the 2,326 distinct products; do not assume every SKU is expected in every store.

## Sales-to-inventory coverage

Match sales to inventory using Product No, Store, Sales Channel, and `Transaction Date BETWEEN Start Date AND End Date`:

| Match outcome | Sales rows | Share |
|---|---:|---:|
| Exactly one active inventory interval | 92,591 | 73.62% |
| Product/store/channel exists, but no interval active that day | 30,443 | 24.21% |
| No product/store/channel inventory key | 2,717 | 2.16% |
| Multiple active intervals | 0 | 0% |

Adding supplier to the key does not change these counts. Keep the two fact tables separate in the model. Do not perform an inner join: it would discard 26.38% of sales rows. Use a separate coverage result or a carefully validated as-of lookup.

## Interpretation limits

The sample supports descriptive analysis, not causal claims. No purchase order, receipt, shipment, promised date, actual delivery date, customer identifier, or valid transaction identifier was found in these schemas. Therefore no lead-time, on-time delivery, fill-rate, procurement performance, customer return rate, or verified stockout rate can be calculated. The dataset description states a 40-store, 2,326-SKU stratified sample across three divisions; retailer identity and full collection methodology are not disclosed in the record.
