SELECT COUNT(DISTINCT stock_code) AS unusual_codes
FROM raw_retail
WHERE stock_code !~ '^[0-9]{5}'
AND price > 0
AND invoice ~ '^[0-9]+$';
SELECT
stock_code,
MIN(description)      AS example_description,
COUNT(*)              AS row_count,
ROUND(AVG(price), 2)  AS avg_price
FROM raw_retail
WHERE stock_code !~ '^[0-9]{5}'
AND price > 0
AND invoice ~ '^[0-9]+$'
GROUP BY stock_code
ORDER BY row_count DESC;
SELECT category, COUNT(*) AS codes
FROM non_product_codes
GROUP BY category
ORDER BY codes DESC;
SELECT current_database();