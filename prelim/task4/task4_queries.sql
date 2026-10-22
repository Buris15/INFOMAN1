-- INFOMAN1 Prelim Lab Exam — Task 4: Sample Data Queries
-- Run toolshare_sample_data.sql first so the tables are populated.
-- Results listed in comments are based on the supplied sample data.

USE toolshare_prelim;

-- Query 1: Names and categories of all tools in Power Tools.
SELECT tool_name, category
FROM tool
WHERE category = 'Power Tools'
ORDER BY tool_id;
-- Expected rows:
-- Cordless Drill | Power Tools
-- Circular Saw   | Power Tools
-- Angle Grinder  | Power Tools

-- Query 2: Members who joined after January 1, 2025.
SELECT member_id, member_name, join_date
FROM member
WHERE join_date > '2025-01-01'
ORDER BY join_date;
-- Expected rows:
-- 5 | Liza Gomez | 2025-01-15
-- 2 | Jose Rizal | 2025-02-10
-- 3 | Ana Reyes  | 2025-06-01
-- 6 | Kevin Lim  | 2025-08-05

-- Query 3: All borrowing records currently on loan.
SELECT borrow_id, member_id, tool_id, borrow_date, return_date
FROM borrowing
WHERE return_date IS NULL
ORDER BY borrow_id;
-- Expected rows:
-- 2 | 1 | 2 | 2025-09-12 | NULL
-- 3 | 2 | 7 | 2025-09-05 | NULL

-- Query 4: All borrowing records for member ID 1 (Maria Santos).
SELECT borrow_id, member_id, tool_id, borrow_date, return_date
FROM borrowing
WHERE member_id = 1
ORDER BY borrow_date;
-- Expected rows:
-- 1 | 1 | 1 | 2025-09-01 | 2025-09-10
-- 2 | 1 | 2 | 2025-09-12 | NULL

-- Query 5: Tools purchased before January 1, 2024.
SELECT tool_id, tool_name, purchase_date
FROM tool
WHERE purchase_date < '2024-01-01'
ORDER BY purchase_date;
-- Expected rows:
-- 1 | Cordless Drill | 2023-05-10
-- 2 | Circular Saw   | 2023-08-22
-- 4 | Garden Shovel  | 2023-12-01
