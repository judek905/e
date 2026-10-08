-- =====================================================================
-- 03 SELECT BASICS
-- Logical order SQL runs a query:  FROM -> WHERE -> GROUP BY -> HAVING
--                                  -> SELECT -> DISTINCT -> ORDER BY -> LIMIT
-- =====================================================================

SELECT * FROM customers;                              -- all columns (avoid in real apps)
SELECT first_name, last_name FROM customers;          -- chosen columns
SELECT first_name AS "First Name" FROM customers;     -- alias
SELECT DISTINCT country FROM customers;               -- unique values

-- ---------- WHERE ----------
SELECT * FROM products WHERE price > 50000;
SELECT * FROM products WHERE price BETWEEN 40000 AND 100000;     -- inclusive
SELECT * FROM products WHERE category_id IN (1, 3);
SELECT * FROM products WHERE category_id NOT IN (1, 3);
SELECT * FROM products WHERE price > 50000 AND stock > 10;
SELECT * FROM products WHERE is_active = FALSE OR stock = 0;
SELECT * FROM products WHERE NOT is_active;

-- ---------- NULL (means "unknown"; never use = NULL) ----------
SELECT * FROM customers WHERE city IS NULL;
SELECT * FROM customers WHERE city IS NOT NULL;
SELECT COALESCE(city, 'Unknown') AS city FROM customers;         -- replace NULL
SELECT NULLIF(stock, 0) FROM products;                           -- returns NULL when stock = 0

-- ---------- Pattern matching ----------
SELECT * FROM customers WHERE first_name LIKE 'A%';       -- starts with A   (% = any characters)
SELECT * FROM customers WHERE email LIKE '%@example.com'; -- ends with
SELECT * FROM customers WHERE first_name LIKE '_race';    -- _ = exactly one character
SELECT * FROM customers WHERE first_name ILIKE 'amina';   -- case-insensitive (PostgreSQL)
SELECT * FROM customers WHERE email ~ '^[a-c]';           -- regular expression

-- ---------- ORDER BY, LIMIT, OFFSET ----------
SELECT * FROM products ORDER BY price DESC;
SELECT * FROM products ORDER BY category_id ASC, price DESC;     -- multiple sort keys
SELECT * FROM products ORDER BY price DESC LIMIT 3;               -- top 3
SELECT * FROM products ORDER BY product_id LIMIT 3 OFFSET 3;      -- page 2 (3 per page)

-- ---------- Expressions and functions ----------
SELECT name, price, price * 0.18 AS vat, price * 1.18 AS price_with_vat FROM products;

-- Text
SELECT UPPER(first_name), LOWER(last_name), LENGTH(email),
       first_name || ' ' || last_name AS full_name,
       SUBSTRING(email FROM 1 FOR 5) AS first_five,
       TRIM('  hello  ') AS trimmed,
       REPLACE(email, 'example.com', 'uni.ac.ug') AS new_email
FROM customers;

-- Numbers
SELECT ROUND(123.456, 2), CEIL(4.1), FLOOR(4.9), ABS(-5), MOD(10, 3), POWER(2, 10);

-- Dates
SELECT CURRENT_DATE, CURRENT_TIMESTAMP, NOW();
SELECT order_id, order_date,
       EXTRACT(YEAR FROM order_date)  AS yr,
       EXTRACT(MONTH FROM order_date) AS mon,
       TO_CHAR(order_date, 'DD Mon YYYY') AS pretty,
       CURRENT_DATE - order_date AS days_ago,
       order_date + INTERVAL '30 days' AS due_date
FROM orders;
SELECT DATE_TRUNC('month', order_date) AS month_start, order_id FROM orders;

-- Casting
SELECT CAST('123' AS INTEGER), '2026-05-01'::DATE, 12::TEXT;

-- ---------- CASE (if/else in SQL) ----------
SELECT name, price,
       CASE
           WHEN price >= 100000 THEN 'Premium'
           WHEN price >= 50000  THEN 'Mid'
           ELSE 'Budget'
       END AS tier
FROM products;
