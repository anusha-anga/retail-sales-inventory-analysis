# KPI definitions

| KPI | Definition | Important caveat |
|---|---|---|
| Net sales | Sum of signed `Sales Amount` | Return rows are negative |
| Gross profit | Net sales − net COGS | Derived measure; depends on supplied COGS values |
| Gross margin % | Gross profit ÷ net sales | Descriptive for this sample; not a forecast |
| Net units | Sum of signed `Qty Sold` | Returns reduce units |
| Positive sales | Sum of Sales Amount where Is Return=0 | Excludes returns |
| Return value | Absolute sum of Sales Amount where Is Return=1 | A value magnitude, not return probability |
| Return-line share | Return rows ÷ all rows | Not a customer return rate; no transaction ID |
| Transaction count | Sum of `Number of Transactions` | Not row count; row count 125,751 vs summed count 131,120 |
| Recorded retail inventory value | Sum of Stocks Selling Amount for active intervals as of date | Formula reconciles to quantity × unit selling price |
| On-hand units | Sum Qty on hand for active intervals as of date | Preserve negative and zero quantities |
| Zero-balance rows | Count active rows with Qty on hand=0 | Not a stockout rate without expected assortment denominator |
| Inventory coverage | Sales rows with exactly one active stock interval ÷ sales rows | 73.62% overall; show unmatched cases |

Never label supplier-attributed sales as supplier performance, or monthly partial April as a complete month.
