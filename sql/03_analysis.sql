USE retail_performance;

-- A) Core sales KPIs. Gross profit/margin are derived from supplied sales and COGS.
SELECT
  SUM(CASE WHEN is_return = 0 THEN sales_amount ELSE 0 END) AS positive_sales,
  SUM(CASE WHEN is_return = 1 THEN sales_amount ELSE 0 END) AS return_sales_signed,
  SUM(sales_amount) AS net_sales,
  SUM(cogs) AS net_cogs,
  SUM(sales_amount) - SUM(cogs) AS gross_profit,
  (SUM(sales_amount) - SUM(cogs)) / NULLIF(SUM(sales_amount), 0) AS gross_margin,
  SUM(qty_sold) AS net_units,
  SUM(number_of_transactions) AS supplied_transaction_count,
  SUM(is_return = 1) / COUNT(*) AS return_line_share
FROM fact_sales;

-- B) Monthly trend. The final month is partial (through 24 April 2026).
SELECT DATE_FORMAT(transaction_date, '%Y-%m') AS sales_month,
       SUM(sales_amount) AS net_sales,
       SUM(qty_sold) AS net_units,
       SUM(number_of_transactions) AS supplied_transaction_count
FROM fact_sales
GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
ORDER BY sales_month;

-- C) Sales mix by category and sales type.
SELECT product_category, sales_type,
       SUM(sales_amount) AS net_sales,
       SUM(qty_sold) AS net_units,
       SUM(number_of_transactions) AS supplied_transaction_count
FROM fact_sales
GROUP BY product_category, sales_type
ORDER BY net_sales DESC;

-- D) Supplier-attributed sales, explicitly not supplier performance.
SELECT supplier, SUM(sales_amount) AS net_sales,
       SUM(qty_sold) AS net_units,
       SUM(number_of_transactions) AS supplied_transaction_count
FROM fact_sales
GROUP BY supplier
ORDER BY net_sales DESC;

-- E) Store sales.
SELECT store_id, SUM(sales_amount) AS net_sales,
       SUM(qty_sold) AS net_units,
       SUM(number_of_transactions) AS supplied_transaction_count
FROM fact_sales
GROUP BY store_id
ORDER BY net_sales DESC;

-- F) Inventory snapshot on the last date in sales, preserving zero/negative rows.
-- This evaluates each validity interval once for the chosen date.
WITH snapshot_date AS (
  SELECT MAX(transaction_date) AS as_of_date FROM fact_sales
)
SELECT d.as_of_date,
       COUNT(*) AS active_inventory_rows,
       COUNT(DISTINCT i.product_no) AS active_products,
       COUNT(DISTINCT i.store_id) AS active_stores,
       SUM(i.qty_on_hand) AS on_hand_units,
       SUM(i.stocks_selling_amount) AS recorded_retail_stock_value,
       SUM(i.cost_of_stocks) AS recorded_stock_cost_unvalidated,
       SUM(i.qty_on_hand = 0) AS zero_balance_rows,
       SUM(i.qty_on_hand < 0) AS negative_balance_rows
FROM snapshot_date d
JOIN fact_inventory i ON d.as_of_date BETWEEN i.start_date AND i.end_date
GROUP BY d.as_of_date;

-- G) Inventory interval coverage by sales row; preserve every sales row.
WITH per_sale AS (
  SELECT s.sales_row_id,
         COUNT(i.inventory_id) AS active_inventory_intervals
  FROM fact_sales s
  LEFT JOIN fact_inventory i
    ON i.product_no = s.product_no
   AND i.store_id = s.store_id
   AND i.sales_channel = s.sales_channel
   AND s.transaction_date BETWEEN i.start_date AND i.end_date
  GROUP BY s.sales_row_id
)
SELECT active_inventory_intervals, COUNT(*) AS sales_rows
FROM per_sale
GROUP BY active_inventory_intervals
ORDER BY active_inventory_intervals;

-- H) Data quality exceptions in inventory cost values.
SELECT COUNT(*) AS mismatch_rows,
       SUM(ABS(cost_of_stocks - qty_on_hand * stock_unit_cost_price) > 1) AS over_one_currency_unit
FROM fact_inventory
WHERE ABS(cost_of_stocks - qty_on_hand * stock_unit_cost_price) > 0.011;
