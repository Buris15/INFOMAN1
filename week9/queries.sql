-- INFOMAN1 Week 9: Required JOIN queries
USE infoman1_canteen;

-- TASK 1: INNER JOIN basics (expected: 3 rows)
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students AS s
INNER JOIN orders AS o
  ON s.student_id = o.student_id
ORDER BY o.order_id;

-- TASK 2(a): Every student, with matching orders where available (expected: 5 rows)
SELECT s.student_id, s.student_name, s.program, o.order_id, o.order_date
FROM students AS s
LEFT JOIN orders AS o
  ON s.student_id = o.student_id
ORDER BY s.student_id, o.order_id;

-- TASK 2(b): Students who never ordered (expected: 2 rows)
SELECT s.student_id, s.student_name, s.program
FROM students AS s
LEFT JOIN orders AS o
  ON s.student_id = o.student_id
WHERE o.order_id IS NULL
ORDER BY s.student_id;

-- TASK 3: Four-table canteen report (expected: 4 rows)
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

-- TASK 4(a): August 2026 order detail report (expected: 4 rows)
SELECT
  s.student_name AS buyer,
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

-- TASK 4(b): The deliberately misleading LEFT JOIN + WHERE version.
-- It returns the same 4 matching line-item rows as Task 4(a),
-- because WHERE removes rows whose o.order_date is NULL.
SELECT
  s.student_name AS buyer,
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

-- TASK 4(c): Corrected LEFT JOIN. Put the date condition in the ON clause
-- to keep all students, including students without August orders (expected: 6 rows).
SELECT
  s.student_name AS buyer,
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

-- Diagnostic counts for Task 4 explanation:
-- Student-to-order LEFT JOIN without a date filter: 5 rows.
SELECT COUNT(*) AS rows_before_where
FROM students AS s
LEFT JOIN orders AS o
  ON s.student_id = o.student_id;

-- Same student-to-order LEFT JOIN with a right-table WHERE date condition: 3 rows.
SELECT COUNT(*) AS rows_after_where
FROM students AS s
LEFT JOIN orders AS o
  ON s.student_id = o.student_id
WHERE o.order_date >= '2026-08-01'
  AND o.order_date < '2026-09-01';

-- Full left-joined line-item report without WHERE: 6 rows (4 item rows + 2 unmatched students).
SELECT COUNT(*) AS all_students_line_rows
FROM students AS s
LEFT JOIN orders AS o
  ON s.student_id = o.student_id
LEFT JOIN order_items AS oi
  ON o.order_id = oi.order_id
LEFT JOIN menu_items AS m
  ON oi.menu_id = m.menu_id;
