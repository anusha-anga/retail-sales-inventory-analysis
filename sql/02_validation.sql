USE retail_performance;

-- 1) Row counts; compare to source audit: inventory 284,755, sales 125,751.
SELECT 'inventory' AS table_name, COUNT(*) AS row_count FROM fact_inventory
UNION ALL
SELECT 'sales', COUNT(*) FROM fact_sales;

-- 2) Missing essential fields and date parsing.
SELECT 'inventory' AS table_name,
       SUM(start_date IS NULL) AS null_dates,
       SUM(product_no IS NULL OR product_no = '') AS missing_product,
       SUM(store_id IS NULL OR store_id = '') AS missing_store
FROM fact_inventory
UNION ALL
SELECT 'sales', SUM(transaction_date IS NULL),
       SUM(product_no IS NULL OR product_no = ''),
       SUM(store_id IS NULL OR store_id = '')
FROM fact_sales;

-- 3) Sales date span, returns, signed-value behavior, and transaction-count sum.
SELECT MIN(transaction_date) AS first_date, MAX(transaction_date) AS last_date,
       COUNT(*) AS rows_loaded,
       SUM(is_return = 1) AS return_rows,
       SUM(is_return = 0) AS non_return_rows,
       SUM(is_return = 1 AND (qty_sold >= 0 OR sales_amount >= 0 OR cogs >= 0)) AS bad_return_sign_rows,
       SUM(is_return = 0 AND (qty_sold < 0 OR sales_amount < 0 OR cogs < 0)) AS bad_nonreturn_sign_rows,
       SUM(number_of_transactions) AS supplied_transaction_count
FROM fact_sales;

-- 4) Inventory arithmetic and negative/zero balances.
SELECT COUNT(*) AS rows_loaded,
       SUM(qty_on_hand < 0) AS negative_qty_rows,
       SUM(qty_on_hand = 0) AS zero_qty_rows,
       SUM(ABS(stocks_selling_amount - qty_on_hand * stock_unit_selling_price) > 0.011) AS retail_value_mismatch_rows,
       SUM(ABS(cost_of_stocks - qty_on_hand * stock_unit_cost_price) > 0.011) AS cost_value_mismatch_rows
FROM fact_inventory;

-- 5) Duplicate source-key test for inventory. Expected: zero duplicate groups.
SELECT COUNT(*) AS duplicate_groups
FROM (
  SELECT start_date, end_date, supplier, product_no, store_id, sales_channel
  FROM fact_inventory
  GROUP BY start_date, end_date, supplier, product_no, store_id, sales_channel
  HAVING COUNT(*) > 1
) d;

-- 6) Sales-to-inventory as-of coverage. Expected counts: 92,591 / 30,443 / 2,717.
WITH match_counts AS (
  SELECT s.sales_row_id, COUNT(i.inventory_id) AS active_rows
  FROM fact_sales s
  LEFT JOIN fact_inventory i
    ON i.product_no = s.product_no
   AND i.store_id = s.store_id
   AND i.sales_channel = s.sales_channel
   AND s.transaction_date BETWEEN i.start_date AND i.end_date
  GROUP BY s.sales_row_id
), key_presence AS (
  SELECT s.sales_row_id,
         EXISTS (SELECT 1 FROM fact_inventory i
                 WHERE i.product_no = s.product_no
                   AND i.store_id = s.store_id
                   AND i.sales_channel = s.sales_channel) AS has_key
  FROM fact_sales s
)
SELECT CASE
         WHEN m.active_rows = 1 THEN 'one_active_interval'
         WHEN m.active_rows > 1 THEN 'multiple_active_intervals'
         WHEN k.has_key = 1 THEN 'key_exists_no_active_interval'
         ELSE 'no_inventory_key'
       END AS match_status,
       COUNT(*) AS sales_rows
FROM match_counts m JOIN key_presence k USING (sales_row_id)
GROUP BY match_status;
