-- MySQL 8.0 template. Update the two paths for your computer before running.
-- Run in a new schema. This script creates tables; it does not edit source CSVs.
-- In Workbench, enable LOCAL INFILE support if your connection requires it.

CREATE DATABASE IF NOT EXISTS retail_performance;
USE retail_performance;

CREATE TABLE IF NOT EXISTS fact_inventory (
  inventory_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  stock_status VARCHAR(40), supplier VARCHAR(40), product_no VARCHAR(40),
  product_description VARCHAR(255), product_division VARCHAR(100),
  product_category VARCHAR(120), product_subcategory VARCHAR(160),
  product_segment VARCHAR(200), store_id VARCHAR(40), store_type VARCHAR(80),
  sales_channel VARCHAR(80), qty_on_hand INT,
  stocks_selling_amount DECIMAL(18,4), cost_of_stocks DECIMAL(18,4),
  stock_unit_selling_price DECIMAL(18,4), stock_unit_cost_price DECIMAL(18,4),
  INDEX ix_inv_asof (product_no, store_id, sales_channel, start_date, end_date)
);

CREATE TABLE IF NOT EXISTS fact_sales (
  sales_row_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  transaction_date DATE NOT NULL,
  sales_type VARCHAR(40), is_return TINYINT,
  reason_of_return VARCHAR(255), supplier VARCHAR(40), product_no VARCHAR(40),
  product_description VARCHAR(255), product_division VARCHAR(100),
  product_category VARCHAR(120), product_subcategory VARCHAR(160),
  product_segment VARCHAR(200), store_id VARCHAR(40), sales_channel VARCHAR(80),
  qty_sold INT, sales_amount DECIMAL(18,4), cogs DECIMAL(18,4),
  number_of_transactions INT,
  INDEX ix_sales_date (transaction_date),
  INDEX ix_sales_product_store (product_no, store_id, sales_channel)
);

-- Edit these paths to match the folder where the CSVs are stored.
-- Character set UTF-8 and comma-delimited CSV with a header row.
LOAD DATA LOCAL INFILE '../data/retail_inventory_ml_apl.csv'
INTO TABLE fact_inventory
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@start_date, @end_date, stock_status, supplier, product_no, product_description,
 product_division, product_category, product_subcategory, product_segment,
 store_id, store_type, sales_channel, qty_on_hand, stocks_selling_amount,
 cost_of_stocks, stock_unit_selling_price, stock_unit_cost_price)
SET start_date = STR_TO_DATE(TRIM(@start_date), '%Y-%m-%d'),
    end_date = STR_TO_DATE(TRIM(@end_date), '%Y-%m-%d');

LOAD DATA LOCAL INFILE '../data/retail_sales_ml_apl.csv'
INTO TABLE fact_sales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_date, sales_type, is_return, reason_of_return, supplier,
 product_no, product_description, product_division, product_category,
 product_subcategory, product_segment, store_id, sales_channel, qty_sold,
 sales_amount, cogs, number_of_transactions)
SET transaction_date = STR_TO_DATE(TRIM(@transaction_date), '%d-%m-%Y');

-- If Workbench reports an empty table, resolve LOCAL INFILE permission first.
-- Verify load row counts with sql/02_validation.sql before analysis.
