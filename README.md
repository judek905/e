# 03: SELECT Basics

A PostgreSQL practice script that teaches how to read data from the `shop_db` database: choosing columns, filtering rows, handling `NULL`, matching patterns, sorting, paging, and using built-in functions. It only reads data; nothing is changed.

## Contents

| File | Purpose |
|------|---------|
| `03_select_basics.sql` | Worked `SELECT` examples on the `customers`, `products`, and `orders` tables |

## Before You Start

Run `01_setup_sample_data.sql` first so the tables and sample data exist.

```bash
psql -U postgres -d shop_db -f 01_setup_sample_data.sql
psql -U postgres -d shop_db -f 03_select_basics.sql
```

Unlike file 02, this script is read-only, so it is safe to run as many times as you like.

## How SQL Runs a Query

The order you write a query is not the order it runs. Logically, SQL processes it as:

```
FROM → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT
```

This is why you can't use a `SELECT` alias inside `WHERE` (the alias doesn't exist yet at that step), but you can use it in `ORDER BY`.

## What Each Section Covers

### Basics
| Example | Idea |
|---------|------|
| `SELECT * FROM customers` | All columns (fine for exploring, avoid in real apps) |
| `SELECT first_name, last_name` | Only the columns you need |
| `AS "First Name"` | Column alias |
| `SELECT DISTINCT country` | Unique values only (3 countries in the sample data) |

### WHERE
| Condition | Rows returned* |
|-----------|----------------|
| `price > 50000` | 6 |
| `price BETWEEN 40000 AND 100000` (inclusive) | 6 |
| `category_id IN (1, 3)` | 6 |
| `category_id NOT IN (1, 3)` | 3 |
| `price > 50000 AND stock > 10` | 5 |
| `is_active = FALSE OR stock = 0` | 1 (Old Phone Case) |
| `NOT is_active` | 1 (Old Phone Case) |

### NULL handling
`NULL` means "unknown", so `= NULL` never works. Use `IS NULL` / `IS NOT NULL`.

| Example | Result |
|---------|--------|
| `city IS NULL` | 1 customer (Grace) |
| `city IS NOT NULL` | 6 customers |
| `COALESCE(city, 'Unknown')` | Replaces `NULL` with a default value |
| `NULLIF(stock, 0)` | Returns `NULL` when stock is 0 (handy to avoid divide-by-zero) |

### Pattern matching
| Example | Meaning | Rows* |
|---------|---------|-------|
| `LIKE 'A%'` | Starts with A (`%` = any characters) | 1 |
| `LIKE '%@example.com'` | Ends with that text | 7 |
| `LIKE '_race'` | `_` = exactly one character (matches Grace) | 1 |
| `ILIKE 'amina'` | Case-insensitive (PostgreSQL only) | 1 |
| `email ~ '^[a-c]'` | Regular expression: email starts with a, b, or c | 3 |

### Sorting and paging
| Example | Result |
|---------|--------|
| `ORDER BY price DESC` | Most expensive first |
| `ORDER BY category_id ASC, price DESC` | Multiple sort keys |
| `ORDER BY price DESC LIMIT 3` | Top 3 by price |
| `ORDER BY product_id LIMIT 3 OFFSET 3` | "Page 2" with 3 rows per page |

### Expressions and functions
| Type | Functions shown |
|------|-----------------|
| Calculations | `price * 0.18` (18% VAT) and `price * 1.18` (price with VAT) |
| Text | `UPPER`, `LOWER`, `LENGTH`, `\|\|` (join text), `SUBSTRING`, `TRIM`, `REPLACE` |
| Numbers | `ROUND`, `CEIL`, `FLOOR`, `ABS`, `MOD`, `POWER` |
| Dates | `CURRENT_DATE`, `CURRENT_TIMESTAMP`, `NOW()`, `EXTRACT`, `TO_CHAR`, date arithmetic, `INTERVAL`, `DATE_TRUNC` |
| Casting | `CAST('123' AS INTEGER)`, `'2026-05-01'::DATE`, `12::TEXT` |

Quick results for the number functions: `ROUND(123.456, 2)` gives 123.46, `CEIL(4.1)` gives 5, `FLOOR(4.9)` gives 4, `ABS(-5)` gives 5, `MOD(10, 3)` gives 1, and `POWER(2, 10)` gives 1024.

### CASE (if/else in SQL)
Labels each product by price:

| Tier | Rule | Products* |
|------|------|-----------|
| Premium | price >= 100,000 | 1 (Mechanical Keyboard) |
| Mid | price >= 50,000 | 5 |
| Budget | everything else | 3 |

\*Counts assume the fresh data from file 01. If you have already run `02_insert_update_delete.sql`, the Books got a 10% price rise, so values such as the top-3 ranking and the tiers will differ (Python Crash Course becomes Premium).

## Notes

- `LIKE` is case-sensitive in PostgreSQL; use `ILIKE` when case shouldn't matter.
- `BETWEEN` includes both end values.
- `OFFSET` paging needs a stable `ORDER BY` (here `product_id`), otherwise pages can overlap or skip rows.
- `CURRENT_DATE - order_date` returns a whole number of days, so `days_ago` changes depending on when you run the query.
- `SELECT *` is handy for exploring, but real applications should list the columns they need.
