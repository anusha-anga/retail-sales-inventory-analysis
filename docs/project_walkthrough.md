# Project walkthrough: every step, tool, and reason

## Project outcome

Build a defensible descriptive report from two related retail files. The data audit and analysis design are complete. To finish the interactive deliverable, the SQL scripts still need to be run against the user's local CSVs and the Power BI model/report needs to be assembled and saved.

| Step | What we do | Tool | Why | Status |
|---|---|---|---|---|
| 1. Set the question | Focus on sales, returns, inventory position, and product/store patterns | Project brief | Keeps analysis tied to a business decision | Complete |
| 2. Choose the data | Use the Mendeley retail sales and stock sample | Mendeley Data record | It contains both sales and inventory with overlapping product/store identifiers | Complete |
| 3. Check provenance | Record DOI, license, stated sample, and what the publisher does not disclose | Mendeley Data page | Provides attribution and makes uncertainty visible | Complete |
| 4. Preserve originals | Read the two CSVs in place; do not edit them | PowerShell read-only profiling | Protects the supplied source and makes the audit repeatable | Complete |
| 5. Inspect structure | Count rows, columns, distinct values, blanks, and date ranges | PowerShell | Confirms the actual schema rather than relying on screenshots | Complete |
| 6. Profile data quality | Check returns, negatives, arithmetic, duplicate keys, and time intervals | PowerShell | Finds anomalies before they become misleading KPIs | Complete |
| 7. Define scope limits | Exclude lead time, delivery, procurement, and causal stockout claims | Data dictionary and audit | The files do not contain PO, receipt, or lead-time evidence | Complete |
| 8. Create database tables | Create separate sales and inventory tables; retain source rows | MySQL 8 / Workbench | SQL makes checks and aggregations reproducible | Prepared; not run |
| 9. Load CSVs | Load dates using each file's distinct format | MySQL `LOAD DATA LOCAL INFILE` | Date parsing differs between source files | Prepared; not run |
| 10. Validate the load | Re-run counts, return checks, formula checks, and key checks | `02_validation.sql` | Confirms database import did not alter or lose data | Prepared; not run |
| 11. Build analysis views | Calculate sales, return, monthly, product, and inventory results | `03_analysis.sql` | Answers the business question using repeatable queries | Prepared; not run |
| 12. Handle the relationship | Keep sales and inventory facts separate; use date-aware inventory coverage | MySQL and Power BI | Avoids dropping unmatched sales or multiplying sales by joining to every stock interval | Designed; build pending |
| 13. Create the semantic model | Add dimensions and one-to-many relationships | Power BI Desktop | Provides consistent filters across the report | Specified; build pending |
| 14. Define measures | Add net sales, net units, margin, returns, and snapshot measures | DAX | Ensures KPI logic is explicit and reusable | Specified; build pending |
| 15. Build report pages | Summary, sales trend, product/store mix, inventory, and data quality | Power BI Desktop | Turns validated results into a decision-friendly view | Specified; build pending |
| 16. Check report numbers | Reconcile visuals against SQL totals and note partial April | Power BI and SQL | Prevents display/model errors and comparison traps | Pending dashboard |
| 17. Explain caveats | Label return-line share, unmatched inventory coverage, and unreliable cost values | Report notes | Prevents readers from treating sample measures as causal or complete | Complete in design |
| 18. Publish portfolio evidence | Save `.pbix`, screenshots, and concise project summary | Power BI / portfolio location | Makes the work reviewable by a hiring manager | Pending user execution |

## Tools used and why

- **PowerShell**: read-only full-file profiling when Excel became unresponsive; used for row counts, ranges, checks, and aggregations without changing source files.
- **MySQL 8 and MySQL Workbench**: planned database layer for repeatable loading, validation, and analysis queries. Scripts are provided but have not been executed on the user's computer.
- **Power BI Desktop**: planned data model and interactive report. The model, pages, and measures are specified; no `.pbix` is represented as finished.
- **Mendeley Data**: provenance and license citation.
- **Excel**: was used by the user to inspect the files, but it is not needed for the remaining data checks. Filtering a large table caused Excel to hang, so use the scripts instead of repeating manual filtering.

## Recommended report pages

1. **Overview**: net sales, gross profit, gross margin, net units, return-line share, and a monthly trend.
2. **Sales mix**: category and product segment contribution, sales type, and supplier-attributed sales.
3. **Store view**: sales by store, with the one-channel limitation stated.
4. **Inventory snapshot**: as-of date, on-hand units, recorded retail value, zero and negative balances, and matching coverage.
5. **Data quality**: unresolved stock-cost reconciliation, unmatched sales-to-stock date coverage, return reason blanks, and sample limits.

## Completion checklist

- [x] Data files profiled without editing originals.
- [x] Key findings and limitations documented.
- [x] SQL schema, load template, validation, and analysis queries prepared.
- [x] Power BI model and DAX plan documented.
- [ ] Run SQL scripts locally and reconcile output.
- [ ] Build and save the Power BI `.pbix` report.
- [ ] Capture report screenshots and write portfolio summary.
