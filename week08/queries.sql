-- INFOMAN1 Week 8 Employee Payroll Query Lab
CREATE DATABASE IF NOT EXISTS infoman1_week8;
USE infoman1_week8;

-- Confirm that the seed data contains exactly 500 employees.
SELECT COUNT(*) AS total_rows FROM employee;

-- TASK 1: Pattern matching
-- 1.1 Last names ending in ez.
SELECT emp_id, first_name, last_name
FROM employee
WHERE last_name LIKE '%ez'
ORDER BY emp_id;

-- 1.2 First names starting with Ma.
SELECT emp_id, first_name, department
FROM employee
WHERE first_name LIKE 'Ma%'
ORDER BY emp_id;

-- 1.3a Exactly five characters, beginning with E; underscores each match one character.
SELECT COUNT(*) AS matching_codes
FROM employee
WHERE emp_code LIKE 'E____';

-- 1.3b A zero in the third character position.
SELECT emp_code, first_name, last_name
FROM employee
WHERE emp_code LIKE 'E_0__'
ORDER BY emp_code;

-- TASK 2: Basic aggregation and NULL handling
SELECT
    COUNT(*) AS total_employees,
    COUNT(commission) AS employees_with_commission,
    SUM(salary) AS monthly_payroll,
    AVG(salary) AS average_salary,
    MIN(hire_date) AS earliest_hire_date,
    MAX(hire_date) AS latest_hire_date,
    SUM(salary + COALESCE(commission, 0)) AS total_compensation
FROM employee;

-- TASK 3.1: Group by department
SELECT
    department,
    COUNT(*) AS headcount,
    AVG(salary) AS average_salary,
    COUNT(DISTINCT job_title) AS distinct_job_titles
FROM employee
GROUP BY department
ORDER BY department;

-- TASK 3.2: Group by department and job title
SELECT
    department,
    job_title,
    COUNT(*) AS headcount
FROM employee
GROUP BY department, job_title
ORDER BY department, job_title;

-- TASK 4.1: Departments whose average salary exceeds the chosen threshold (75,000).
SELECT
    department,
    AVG(salary) AS average_salary
FROM employee
GROUP BY department
HAVING AVG(salary) > 75000
ORDER BY average_salary DESC;

-- TASK 4.2: Departments with more than 50 active employees.
SELECT
    department,
    COUNT(*) AS active_headcount
FROM employee
WHERE status = 'Active'
GROUP BY department
HAVING COUNT(*) > 50
ORDER BY active_headcount DESC;
