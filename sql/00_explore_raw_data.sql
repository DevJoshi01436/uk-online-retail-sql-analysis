SELECT COUNT(*) AS total_rows
FROM raw_retail;
-- Result: 1067371 rows are there in total
SELECT *
FROM raw_retail
LIMIT 20;
-- Result: Each row is one product line within an invoice.
-- Line revenue = quantity * price. customer_id stored as decimal (e.g. 13085.0).
-- Some descriptions have leading spaces. Stock codes can contain letters
SELECT
MIN(invoice_date)AS first_date,
max(invoice_date)AS last_date
from raw_retail;
-- Result: 2009-12-01 07:45 to 2011-12-09 12:50 (just over 2 years).
-- Note: December 2011 only has 9 days, so it is a partial month.SELECT
SELECT
count (DISTINCT invoice) As Unique_invoices,
count (distinct stock_code)As unique_products,
count (distinct customer_id)As unique_customers,
count (distinct country)As unique_countries
from raw_retail;
-- Result: invoice= 53628, products= 5305, customers=5942, counties= 43
-- About 20 lines per invoice on average (wholesale-style orders).
-- Customer count excludes rows with no customer_id.
SELECT
count(*) - count(stock_Code) As missing_stock_code,
count(*) - count(invoice)as missing_invoice,
count(*) - count(description) as missing_description,
count(*) - count(quantity) as missing_quantity,
count(*) - count(invoice_date) as missing_invoice_date,
count(*) - count(price) as missing_price,
count(*) - count(customer_id) as missing_customer_id,
count(*) - count(country) as missing_country
from raw_retail;
-- Result: description missing in 4,382 rows (0.4%).
-- customer_id missing in 243,007 rows (22.8%). All other columns complete.
-- Decision: keep rows without customer_id for sales analysis,
-- exclude them only for customer-level analysis (e.g. RFM).
SELECT count(*) As cancelled_rows
from raw_retail
where invoice like 'c%';
SELECT invoice, COUNT(*) AS row_count
FROM raw_retail
WHERE invoice !~ '^[0-9]+$'
GROUP BY invoice
ORDER BY row_count DESC
LIMIT 20;
SELECT
COUNT(*) FILTER (WHERE invoice LIKE 'C%') AS starts_with_c,
COUNT(*) FILTER (WHERE invoice LIKE '%C%') AS contains_c,
COUNT(*) FILTER (WHERE invoice !~ '^[0-9]+$') AS not_just_numbers
FROM raw_retail;
-- Result: 19,494 cancelled rows (invoice starts with 'C'), about 1.8% of data.
-- Also found 6 rows with non-numeric invoices that are not cancellations
-- (checked separately with a regex query).
select count(*) as negative_quantity
from raw_retail
where quantity <= 0;
SELECT
CASE WHEN invoice LIKE 'C%' THEN 'Cancelled' ELSE 'Not cancelled' END AS invoice_type,
COUNT(*) AS rows_with_non_positive_quantity,
COUNT(*) FILTER (WHERE description IS NULL) AS missing_description,
COUNT(*) FILTER (WHERE price = 0) AS zero_price
FROM raw_retail
WHERE quantity <= 0
GROUP BY invoice_type;
-- Result: 22,950 rows with quantity <= 0.
-- 19,494 are cancellations; about 3,456 are not (likely stock adjustments).@?
SELECT *
FROM raw_retail
WHERE invoice !~ '^[0-9]+$'
AND invoice NOT LIKE 'C%';
SELECT COUNT(*) AS non_positive_price
FROM raw_retail
WHERE price <= 0;
SELECT
CASE
WHEN price < 0 THEN 'Negative price'
WHEN quantity <= 0 THEN 'Zero price, quantity <= 0'
ELSE 'Zero price, quantity > 0'
END AS price_group,
COUNT(*) AS row_count,
COUNT(*) FILTER (WHERE description IS NULL) AS missing_description,
COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer
FROM raw_retail
WHERE price <= 0
GROUP BY price_group;
-- Result: 6,225 rows with price <= 0:
--   5 negative price (bad debt adjustments)
--   3,457 zero price, quantity <= 0 (stock adjustments)
--   2,763 zero price, quantity > 0 (mostly stock adjustments; 89 have a customer,
--   possibly free samples)
-- All 4,382 missing descriptions are in zero-price rows.
-- Decision: remove all rows with price <= 0 (not real sales).
SELECT *
FROM raw_retail
WHERE invoice LIKE 'C%'
AND quantity > 0;
SELECT COUNT(*) AS duplicate_rows
FROM (
SELECT *, COUNT(*) OVER (
PARTITION BY invoice, stock_code, description, quantity,
invoice_date, price, customer_id, country
) AS copies
FROM raw_retail
) t
WHERE copies > 1;
-- Result: 67,242 rows are part of a duplicate group (including originals).
-- Extra copies to remove: (see next query)
-- Note: C496350 is a cancelled 'Manual' adjustment (stock code 'M'), not a product.
SELECT country, COUNT(*) AS row_count
FROM raw_retail
GROUP BY country
ORDER BY row_count DESC
LIMIT 10;
SELECT stock_code, description, COUNT(*) AS row_count
FROM raw_retail
WHERE stock_code !~ '^[0-9]{5}'
GROUP BY stock_code, description
ORDER BY row_count DESC
LIMIT 20;
SELECT COUNT(*) AS extra_copies_to_remove
FROM (
SELECT ROW_NUMBER() OVER (
PARTITION BY invoice, stock_code, description, quantity,
invoice_date, price, customer_id, country
) AS copy_number
FROM raw_retail
) t
WHERE copy_number > 1;
-- Result: 67,242 rows are part of a duplicate group (including originals).
-- Extra copies to remove: 34,335 (3.2% of all rows).
-- Note: C496350 is a cancelled 'Manual' adjustment (stock code 'M'), not a product.
-- Query 10 result: UK is by far the largest; then EIRE (Ireland) 17,866,
-- Germany 17,624, France 14,330, Netherlands 5,140.

-- Query 11 result: non-standard codes include non-products (POST, M Manual,
-- C2 Carriage, D Discount, BANK CHARGES, AMAZONFEE, ADJUST, CRUK, TEST001),
-- gift vouchers, samples (S), AND some real products (DCGS..., PADS).
-- Decision: exclude an explicit list of non-product codes, not all
-- non-standard codes.