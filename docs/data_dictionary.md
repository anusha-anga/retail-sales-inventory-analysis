# Data dictionary and model

## Inventory CSV (`retail_inventory_ml_apl.csv`)

| Source column | Meaning / use | Type guidance |
|---|---|---|
| Start Date | Beginning of stock record validity | Date, CSV `YYYY-MM-DD` |
| End Date | Last date of validity; `9999-12-31` means open-ended sentinel | Date |
| Stock Status | Price/promotion status | Text category |
| Supplier | Supplier label recorded for the stock row | Text; anonymized label |
| Product No | Product identifier | Text, preserve leading zeros |
| Product Description | Human-readable product/segment text | Text |
| Product Division | Highest supplied product group | Text |
| Product Category | Category | Text |
| Product Subcategory | Subcategory | Text |
| Product Segment | Segment | Text |
| Store | Store identifier | Text |
| Store Type | Store format | Text |
| Sales Channel | Sales channel | Text |
| Qty on hand | Recorded units on hand; includes negative and zero values | Whole number |
| Stocks Selling Amount | Recorded retail value of stock | Decimal(15,2) |
| Cost of Stocks | Recorded cost value; reconciliation issues found | Decimal(15,4), use cautiously |
| Stock Unit Selling Price | Unit selling price | Decimal(15,4) |
| Stock Unit Cost Price | Unit cost; some negative values present | Decimal(15,4), use cautiously |

## Sales CSV (`retail_sales_ml_apl.csv`)

| Source column | Meaning / use | Type guidance |
|---|---|---|
| Transaction Date | Date of recorded sales row | Date, CSV `DD-MM-YYYY` |
| Sales Type | Full price, promo, markdown, clearance | Text category |
| Is Return | 1 indicates return row, 0 otherwise | Whole number / Boolean |
| Reason of Return | Return reason; blank in every row | Text, currently unusable |
| Supplier | Supplier label associated with the sale | Text |
| Product No | Product identifier | Text |
| Product Description | Product description | Text |
| Product Division | Division | Text |
| Product Category | Category | Text |
| Product Subcategory | Subcategory | Text |
| Product Segment | Segment | Text |
| Store | Store identifier | Text |
| Sales Channel | Channel | Text |
| Qty Sold | Signed units; returns are negative | Whole number |
| Sales Amount | Signed sales value; returns are negative | Decimal(15,2) |
| Cogs | Signed cost of goods sold; returns are negative | Decimal(15,4) |
| Number of Transactions | Transaction count represented by row | Whole number; do not substitute row count |

## Recommended Power BI model

Keep two fact tables:

- `FactSales`, one row per supplied sales row. It has no transaction identifier; inferred composite row grain is Date × Sales Type × Return flag × Supplier × Product × Store × Channel.
- `FactInventory`, one row per supplied stock-validity interval. Its unique source key is Start Date × End Date × Supplier × Product × Store × Channel.

Create dimensions from consistent product attributes (`DimProduct`), store (`DimStore`), supplier (`DimSupplier`), sales channel (`DimChannel`), and separate calendar tables for sales date and inventory dates as needed. Use one-to-many, single-direction relationships from dimensions to facts. Avoid a direct relationship between fact tables. For common product/store slicers, use shared dimensions; supplier remains descriptive and may not align perfectly between facts.

Inventory is a validity interval, not a daily snapshot. To report a selected date, filter inventory to rows where Start Date ≤ selected date and End Date ≥ selected date. A normal relationship from Calendar to Start Date does not implement this interval logic. Use a clearly scoped snapshot query/table or a DAX measure with an explicit single selected date. The 9999 sentinel should be handled as an open-ended date.
