# Week 10 — Expected Query Outputs

## Task 1 — INSERT confirmations

After inserting the Scientific Calculator:

| product_id | product_name | sku | price | stock_quantity | status |
|---:|---|---|---:|---:|---|
| 6 | Scientific Calculator | CALC-SCI-001 | 850.00 | 20 | Active |

After inserting the Compass:

| product_id | product_name | sku | price | stock_quantity | status |
|---:|---|---|---:|---:|---|
| 7 | Compass | CMP-001 | 120.00 | 50 | Active |

Each INSERT should affect one row. Each SELECT should return one row.

## Task 2 — UPDATE and DELETE confirmations

Calculator preview, before UPDATE:

| product_id | product_name | sku | price |
|---:|---|---|---:|
| 6 | Scientific Calculator | CALC-SCI-001 | 850.00 |

Calculator verification, after UPDATE:

| product_id | product_name | sku | price |
|---:|---|---|---:|
| 6 | Scientific Calculator | CALC-SCI-001 | 875.00 |

The DELETE should affect one row. The verification SELECT for `product_id = 5` should return **0 rows**, because the Eraser was deleted.

## Task 3 — JOIN outputs

Self join:

| employee_id | employee_name | manager_name |
|---:|---|---|
| 1 | Lea Ramos | NULL |
| 2 | Carlo Reyes | Lea Ramos |
| 3 | Dana Cruz | Lea Ramos |

Expected self-join row count: **3**.

CROSS JOIN (ordered by color, then size):

| color_name | size_name |
|---|---|
| Blue | L |
| Blue | M |
| Blue | S |
| Green | L |
| Green | M |
| Green | S |
| Red | L |
| Red | M |
| Red | S |

The count query should return:

| total_color_size_pairs |
|---:|
| 9 |

Calculation: 3 colors × 3 sizes = **9 pairs**.

## Task 4 — Constraints and test writes

The three pre-constraint data-check queries should return no rows (and the duplicate-SKU query should return no groups).

The three valid test INSERTs should each affect one row. On a fresh run, their confirmation queries should return:

| product_id | product_name | sku | price |
|---:|---|---|---:|
| 8 | NOT NULL valid test | TEST-NN-001 | 10.00 |
| 9 | UNIQUE valid test | TEST-UNIQUE-001 | 10.00 |
| 10 | CHECK valid test | TEST-CHECK-001 | 10.00 |

The three invalid INSERTs should each be rejected:

| Test | Invalid value | Expected reason |
|---|---|---|
| NOT NULL | `product_name = NULL` | `product_name` cannot be NULL |
| UNIQUE | `sku = 'NB-001'` | That SKU is already used by Notebook |
| CHECK | `price = 0.00` | Price must be greater than zero |

Run each invalid INSERT separately. Do not uncomment all three and run them as one batch. The exact message/code depends on the MySQL or MariaDB version. Make sure the zero-price test is actually rejected; this confirms that the server enforces CHECK constraints.

## Final products table

After both Task 1 inserts, the Calculator UPDATE, the Eraser DELETE, and the three valid Task 4 test inserts, the expected rows are:

| product_id | product_name | sku | price |
|---:|---|---|---:|
| 1 | Notebook | NB-001 | 45.00 |
| 2 | Ballpen | BP-001 | 15.00 |
| 3 | USB Drive | USB-001 | 350.00 |
| 4 | Ruler | RL-001 | 25.00 |
| 6 | Scientific Calculator | CALC-SCI-001 | 875.00 |
| 7 | Compass | CMP-001 | 120.00 |
| 8 | NOT NULL valid test | TEST-NN-001 | 10.00 |
| 9 | UNIQUE valid test | TEST-UNIQUE-001 | 10.00 |
| 10 | CHECK valid test | TEST-CHECK-001 | 10.00 |

Expected final product count: **9**.

## Local evidence to add

Capture your actual phpMyAdmin/MySQL result screens for Task 1, Task 2, Task 3, the `SHOW CREATE TABLE` result, the three valid inserts, and each of the three rejected inserts. Also record the value returned by `SELECT VERSION()`. Do not use this expected-output reference as a substitute for actual server screenshots if your instructor requires screenshots.
