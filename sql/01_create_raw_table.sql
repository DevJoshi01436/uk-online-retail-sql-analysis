-- =====================================================================
-- 01_create_raw_table.sql
-- Project: UK Online Retail SQL Analysis
-- Purpose: Create a raw (staging) table and load the Online Retail II data
-- Source:  Online Retail II dataset (UCI Machine Learning Repository / Kaggle)
-- =====================================================================

-- Start fresh if you need to re-run this script
DROP TABLE IF EXISTS raw_retail;

-- Raw table: mirrors the CSV exactly, no cleaning yet.
-- invoice is TEXT because cancelled invoices start with the letter 'C'.
-- stock_code is TEXT because some codes contain letters (e.g. 'POST').
-- customer_id is NUMERIC because the CSV stores it like '13085.0'.
CREATE TABLE raw_retail (
    invoice       TEXT,
    stock_code    TEXT,
    description   TEXT,
    quantity      INTEGER,
    invoice_date  TIMESTAMP,
    price         NUMERIC(10, 2),
    customer_id   NUMERIC,
    country       TEXT
);

-- ---------------------------------------------------------------------
-- Load the CSV.
-- Run this line in psql (the SQL Shell), NOT in the pgAdmin query tool.
-- The path below assumes the CSV is saved in your project's data folder.
-- (use forward slashes / even on Windows)
-- ---------------------------------------------------------------------
\copy raw_retail FROM 'C:/Users/devj0/Documents/Projects/uk-online-retail-sql-analysis/data/online_retail_II.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- If you get an encoding error, run the same line with ENCODING 'LATIN1' instead.

-- Quick check that the load worked (expect roughly 1.07 million rows)
SELECT COUNT(*) AS total_rows FROM raw_retail;
