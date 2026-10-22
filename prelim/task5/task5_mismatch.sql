-- INFOMAN1 Prelim Lab Exam — Task 5: Cross-Week Mismatch
USE toolshare_prelim;

-- ORIGINAL BROKEN QUERY (intentionally kept commented so the whole file can run):
-- SELECT borrow_date, return_date
-- FROM borrowing
-- WHERE member_name = 'Maria Santos';
-- This fails because member_name is not a column in borrowing.

-- Corrected query 1: look up Maria Santos's member ID in the member table.
SELECT member_id, member_name
FROM member
WHERE member_name = 'Maria Santos';
-- Expected: member_id = 1, member_name = Maria Santos

-- Corrected query 2: use that ID to filter borrowing (single-table query).
SELECT borrow_date, return_date
FROM borrowing
WHERE member_id = 1
ORDER BY borrow_date;
-- Expected:
-- 2025-09-01 | 2025-09-10
-- 2025-09-12 | NULL
