-- =====================================================================
-- 00_explore_raw_data.sql
-- Project: UK Online Retail SQL Analysis
-- Purpose: Understand the raw data BEFORE cleaning it.
-- Tip: write the result of each query as a comment underneath it.
--      These notes become the "Data quality" section of your README.
-- =====================================================================


-- 1. How many rows are there?
SELECT COUNT(*) AS total_rows
FROM raw_retail;
-- Result:


-- 2. Look at a sample of the data
SELECT *
FROM raw_retail
LIMIT 20;


-- 3. What date range does the data cover?
SELECT
    MIN(invoice_date) AS first_date,
    MAX(invoice_date) AS last_date
FROM raw_retail;
-- Result:


-- 4. How many unique invoices, products, customers and countries?
SELECT
    COUNT(DISTINCT invoice)     AS unique_invoices,
    COUNT(DISTINCT stock_code)  AS unique_products,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT country)     AS unique_countries
FROM raw_retail;
-- Result:


-- 5. Missing values in each column
-- (COUNT(column) ignores NULLs, so total minus COUNT(column) = missing)
SELECT
    COUNT(*) - COUNT(invoice)      AS missing_invoice,
    COUNT(*) - COUNT(stock_code)   AS missing_stock_code,
    COUNT(*) - COUNT(description)  AS missing_description,
    COUNT(*) - COUNT(quantity)     AS missing_quantity,
    COUNT(*) - COUNT(invoice_date) AS missing_date,
    COUNT(*) - COUNT(price)        AS missing_price,
    COUNT(*) - COUNT(customer_id)  AS missing_customer_id,
    COUNT(*) - COUNT(country)      AS missing_country
FROM raw_retail;
-- Result:


-- 6. How many rows are cancellations? (invoice starts with 'C')
SELECT COUNT(*) AS cancelled_rows
FROM raw_retail
WHERE invoice LIKE 'C%';
-- Result:


-- 7. Rows with zero or negative quantity
SELECT COUNT(*) AS non_positive_quantity
FROM raw_retail
WHERE quantity <= 0;
-- Result:


-- 8. Rows with zero or negative price
SELECT COUNT(*) AS non_positive_price
FROM raw_retail
WHERE price <= 0;
-- Result:


-- 9. Exact duplicate rows
SELECT COUNT(*) AS duplicate_rows
FROM (
    SELECT *, COUNT(*) OVER (
        PARTITION BY invoice, stock_code, description, quantity,
                     invoice_date, price, customer_id, country
    ) AS copies
    FROM raw_retail
) t
WHERE copies > 1;
-- Result:


-- 10. Top 10 countries by number of rows
SELECT
    country,
    COUNT(*) AS row_count
FROM raw_retail
GROUP BY country
ORDER BY row_count DESC
LIMIT 10;
-- Result:


-- 11. Strange stock codes (not normal products, e.g. postage, fees)
SELECT
    stock_code,
    description,
    COUNT(*) AS row_count
FROM raw_retail
WHERE stock_code !~ '^[0-9]{5}'
GROUP BY stock_code, description
ORDER BY row_count DESC
LIMIT 20;
-- Result:
