# Power BI measures

Create these measures after loading `FactSales`. Format currency as appropriate for your report and margin as percentage. These formulas assume signed returns in the source.

```DAX
Net Sales = SUM(FactSales[Sales Amount])

Positive Sales =
CALCULATE([Net Sales], FactSales[Is Return] = 0)

Return Sales (Signed) =
CALCULATE([Net Sales], FactSales[Is Return] = 1)

Return Value = -[Return Sales (Signed)]

Net COGS = SUM(FactSales[Cogs])

Gross Profit = [Net Sales] - [Net COGS]

Gross Margin % = DIVIDE([Gross Profit], [Net Sales])

Net Units = SUM(FactSales[Qty Sold])

Transaction Count (Supplied) = SUM(FactSales[Number of Transactions])

Sales Rows = COUNTROWS(FactSales)

Return Line Share =
DIVIDE(
    CALCULATE([Sales Rows], FactSales[Is Return] = 1),
    [Sales Rows]
)
```

Do not label Return Line Share as a customer return rate. For inventory, create a single-select as-of date parameter/table disconnected from `FactInventory`. Use this measure for a selected date (adjust the date parameter table name if needed):

```DAX
On Hand Units (As Of) =
VAR AsOfDate = SELECTEDVALUE('As Of Date'[Date])
RETURN
IF(
    ISBLANK(AsOfDate),
    BLANK(),
    CALCULATE(
        SUM(FactInventory[Qty on hand]),
        FILTER(
            ALL(FactInventory[Start Date], FactInventory[End Date]),
            FactInventory[Start Date] <= AsOfDate
                && FactInventory[End Date] >= AsOfDate
        )
    )
)

Recorded Retail Value (As Of) =
VAR AsOfDate = SELECTEDVALUE('As Of Date'[Date])
RETURN
IF(
    ISBLANK(AsOfDate),
    BLANK(),
    CALCULATE(
        SUM(FactInventory[Stocks Selling Amount]),
        FILTER(
            ALL(FactInventory[Start Date], FactInventory[End Date]),
            FactInventory[Start Date] <= AsOfDate
                && FactInventory[End Date] >= AsOfDate
        )
    )
)
```

Use a separate SQL-generated coverage table if you want a match percentage. A naïve DAX relationship between the facts will duplicate values or filter sales incorrectly.
