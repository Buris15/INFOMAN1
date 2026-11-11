# INFOMAN1 — Week 9 Lab Answers

Name: **Lacsamana, Adrian D.**  
Student ID: **2510955**  
GitHub repo: https://github.com/Buris15/infoman1  
Date submitted: **November 11, 2026**

## Dataset Setup

I created the `infoman1_canteen` database and ran the supplied seed script. The dataset contains 4 students, 3 orders, 3 menu items, and 4 order-item records. The seed verification is in `seed_verification.txt`.

## Task 1 — INNER JOIN Basics

**Approach / explanation:**

I joined `students` and `orders` using their shared `student_id` key. I used an `INNER JOIN`, so only students with matching orders appear. I sorted the result by `order_id` to show the orders in ascending order.

**Code / query used:**

```sql
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students AS s
INNER JOIN orders AS o
  ON s.student_id = o.student_id
ORDER BY o.order_id;
```

**Evidence:** `task1_results.txt` — 3 rows: Ana Cruz (orders 101 and 102) and Dan Reyes (order 103).

**Reflection question:**

An `INNER JOIN` hides students who never ordered because they have no matching row in the `orders` table. This is useful for a sales report that should show only actual orders or buyers, not every enrolled student.

## Task 2 — Finding Missing Relationships

**Approach / explanation:**

For part (a), I used a `LEFT JOIN` so every student appears even when there is no matching order. For part (b), I added `WHERE o.order_id IS NULL` to keep only the unmatched students. Ben Lim and Cara Yu appear in part (b) because neither has an order record.

**Code / query used:**

```sql
-- (a) Show all students and any matching order
SELECT s.student_id, s.student_name, s.program,
       o.order_id, o.order_date
FROM students AS s
LEFT JOIN orders AS o
  ON s.student_id = o.student_id
ORDER BY s.student_id, o.order_id;

-- (b) Show students who never ordered
SELECT s.student_id, s.student_name, s.program
FROM students AS s
LEFT JOIN orders AS o
  ON s.student_id = o.student_id
WHERE o.order_id IS NULL
ORDER BY s.student_id;
```

**Evidence:** `task2_results.txt` — part (a) returns 5 rows; part (b) returns 2 rows (Ben Lim and Cara Yu).

**Reflection question:**

`NULL` in the order columns means that the student has no matching order. I use `IS NULL` because `NULL` represents a missing or unknown value; it cannot be tested correctly with `= NULL`.

## Task 3 — Four-Table Canteen Report

**Approach / explanation:**

I joined the four tables through their primary-key and foreign-key relationships. Each join has its own `ON` condition: students to orders, orders to order items, and order items to menu items. I also calculated each line total by multiplying the quantity by the menu price.

**Code / query used:**

```sql
SELECT
  s.student_name,
  s.program,
  o.order_id,
  m.item_name,
  oi.quantity,
  m.price,
  oi.quantity * m.price AS line_total
FROM students AS s
INNER JOIN orders AS o
  ON s.student_id = o.student_id
INNER JOIN order_items AS oi
  ON o.order_id = oi.order_id
INNER JOIN menu_items AS m
  ON oi.menu_id = m.menu_id
ORDER BY o.order_id, m.item_name;
```

**Evidence:** `task3_results.txt` — 4 line-item rows. The line totals are ₱30.00, ₱130.00, ₱89.00, and ₱65.00.

**Reflection question:**

Each `JOIN` needs its own `ON` condition to tell MySQL which key connects the next table. Without the correct condition, the query can fail or combine unrelated rows and produce incorrect results.

## Task 4 — Aliases, Filters, and the Silent Inner Join

**Approach / explanation:**

I first created an August 2026 order report using `INNER JOIN` and a date filter. Then I repeated the report using `LEFT JOIN` but placed the date condition in `WHERE`. That condition removes rows where the order date is `NULL`, so the second query no longer preserves students who did not order. Moving the date condition into the `ON` clause keeps all students in the corrected `LEFT JOIN` version.

**Code / query used:**

```sql
-- (a) August 2026 order report using INNER JOIN
SELECT s.student_name AS buyer,
       o.order_id,
       o.order_date,
       m.item_name,
       oi.quantity,
       oi.quantity * m.price AS line_total
FROM students AS s
INNER JOIN orders AS o
  ON s.student_id = o.student_id
INNER JOIN order_items AS oi
  ON o.order_id = oi.order_id
INNER JOIN menu_items AS m
  ON oi.menu_id = m.menu_id
WHERE o.order_date >= '2026-08-01'
  AND o.order_date < '2026-09-01'
ORDER BY o.order_date DESC, o.order_id DESC, m.item_name;

-- (b) LEFT JOIN with the date condition in WHERE (demonstrates the issue)
SELECT s.student_name AS buyer,
       o.order_id,
       o.order_date,
       m.item_name,
       oi.quantity,
       oi.quantity * m.price AS line_total
FROM students AS s
LEFT JOIN orders AS o
  ON s.student_id = o.student_id
LEFT JOIN order_items AS oi
  ON o.order_id = oi.order_id
LEFT JOIN menu_items AS m
  ON oi.menu_id = m.menu_id
WHERE o.order_date >= '2026-08-01'
  AND o.order_date < '2026-09-01'
ORDER BY o.order_date DESC, o.order_id DESC, m.item_name;

-- (c) Fix: put the date condition in the orders ON clause
SELECT s.student_name AS buyer,
       o.order_id,
       o.order_date,
       m.item_name,
       oi.quantity,
       CASE
         WHEN oi.quantity IS NULL OR m.price IS NULL THEN NULL
         ELSE oi.quantity * m.price
       END AS line_total
FROM students AS s
LEFT JOIN orders AS o
  ON s.student_id = o.student_id
 AND o.order_date >= '2026-08-01'
 AND o.order_date < '2026-09-01'
LEFT JOIN order_items AS oi
  ON o.order_id = oi.order_id
LEFT JOIN menu_items AS m
  ON oi.menu_id = m.menu_id
ORDER BY o.order_date DESC, s.student_name, m.item_name;
```

**Evidence:** `task4_results.txt` — the filtered `INNER JOIN` report returns 4 line-item rows. The `LEFT JOIN` plus `WHERE` version also returns 4 rows, but it has lost the two non-buyers and therefore behaves like an inner join for this filter. The corrected `LEFT JOIN` with the date rule in `ON` returns 6 rows: the 4 order-item rows plus Ben and Cara with `NULL` order/item columns. At the student-to-order level, the unfiltered `LEFT JOIN` has 5 rows, while adding the date condition in `WHERE` leaves only 3 matched order rows.

**Reflection question:**

The `WHERE` clause filters the completed joined result. For a student without an order, `o.order_date` is `NULL`, so the date comparison is not true and the row is removed. Put the date condition in the `ON` clause when the goal is to keep every student, or explicitly allow `o.order_date IS NULL` in the `WHERE` condition.

## Task 5 — Reflection

**Approach / explanation:**

I compared the results of the `INNER JOIN` and `LEFT JOIN` queries from the earlier tasks. I used the canteen example to explain when each join is appropriate and described the filtering issue demonstrated in Task 4.

**150–200 word reflection:**

I would use an `INNER JOIN` when a report should show only records that have a matching relationship. For example, in Task 1, the query joins students with orders, so the result includes only Ana Cruz and Dan Reyes because they placed orders. This is useful for a completed-sales report because students without purchases should not appear. I would use a `LEFT JOIN` when the report must include every record from the main table, even if there is no match. In Task 2, it keeps all four students visible and shows `NULL` for Ben Lim and Cara Yu because they have no orders.

While testing Task 4, I observed that adding `WHERE o.order_date >= '2026-08-01'` to a `LEFT JOIN` removed students whose order date was `NULL`. The output no longer included the non-buyers, even though I had used a `LEFT JOIN`. I fixed this by moving the date condition into the `ON` clause of the join. This keeps all students while matching only orders within the required date range.

**Evidence:** The reflection is included here; Task 4's before-and-after outputs are in `task4_results.txt`.

## Self-Check

- [ ] Name, student ID, GitHub username, and submission date filled in
- [ ] All SQL queries run in MySQL Workbench or the MySQL CLI
- [ ] Screenshots or exported outputs saved inside `week9/`
- [ ] All files placed inside `week9/`
- [ ] Files committed with meaningful commit messages
- [ ] Repository link pasted into Moodle (no files uploaded)
