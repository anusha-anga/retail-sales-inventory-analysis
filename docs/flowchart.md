# Project flowchart

```mermaid
flowchart TD
    A[Business question: sales and inventory performance] --> B[Choose retail sales and stock dataset]
    B --> C[Preserve original CSV files]
    C --> D[Profile columns, dates, blanks, and key counts]
    D --> E{Data quality checks}
    E -->|Return signs, formulas, duplicate keys, intervals| F[Document exceptions and caveats]
    F --> G[Load separate Sales and Inventory tables in MySQL]
    G --> H[Validate row counts and parsed dates]
    H --> I[Analyze net sales, returns, categories, stores, and monthly trends]
    I --> J[Match sales to inventory by product, store, channel, and active date]
    J --> K[Keep unmatched sales and report coverage]
    K --> L[Build Power BI model with separate fact tables]
    L --> M[Create KPI measures and report pages]
    M --> N[Reconcile report totals to SQL]
    N --> O[Save PBIX and portfolio summary]
```

## What each arrow means

1. Agree the question and narrow scope to what these files support.
2. Record the source and attribution details.
3. Read the originals without editing them.
4. Learn the actual field names, row counts, and date ranges.
5. Check the values and relationships before calculating results.
6. Make limitations visible rather than hiding or “fixing” them without evidence.
7. Load two separate tables; do not flatten intervals into daily stock rows.
8. Confirm the database matches the input files.
9. Calculate business measures at their valid grain.
10. Use an as-of interval match, not just a product lookup.
11. Preserve sales rows even where no stock interval is available.
12. Model dimensions filtering each fact table independently.
13. Build clear reusable measures and visuals.
14. Compare dashboard cards with known query totals.
15. Save the reviewable final dashboard and short explanation.

The data audit and this flowchart are complete. Database execution and the final Power BI file remain to be done in MySQL Workbench and Power BI Desktop.
