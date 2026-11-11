# INFOMAN1 — Week 8 Lab Answers

Name: Lacsamana, Adrian D.
Student ID: 2510955
GitHub repo: https://github.com/Buris15/infoman1  
Date submitted: November 11, 2026

**Dataset check:** `SELECT COUNT(*) FROM employee;` returned: **500**.

## Task 1 — Pattern Matching Basics

**Approach / explanation:**
I used `LIKE` with `%` to search for names that begin or end with a specific set of letters. I used `_` to match exactly one character in the employee codes. The seed data contains 500 employee records, and the query results are saved in `task1_results.txt`.

**Code / query used:**
```sql
-- 1.1 Last names ending in ez (161 rows)
SELECT emp_id, first_name, last_name
FROM employee
WHERE last_name LIKE '%ez'
ORDER BY emp_id;

-- 1.2 First names starting with Ma (112 rows)
SELECT emp_id, first_name, department
FROM employee
WHERE first_name LIKE 'Ma%'
ORDER BY emp_id;

-- 1.3a Prove all 500 codes are 5 characters and start with E
SELECT COUNT(*) AS matching_codes
FROM employee
WHERE emp_code LIKE 'E____';
-- Result: 500

-- 1.3b Codes with 0 as the third character (48 rows)
SELECT emp_code, first_name, last_name
FROM employee
WHERE emp_code LIKE 'E_0__'
ORDER BY emp_code;
```

**Evidence / row counts:**
- `LIKE '%ez'`: **161 rows**.
- `LIKE 'Ma%'`: **112 rows**.
- `LIKE 'E____'`: **500 rows**.
- `LIKE 'E_0__'`: **48 rows**.
- Full result rows are recorded in `task1_results.txt`.

**Reflection question:**
We use `%` because it can match any number of characters, including none. The `_` wildcard matches exactly one character, so it is useful when the character position or length is fixed.

## Task 2 — Basic Aggregation

**Approach / explanation:**
I used aggregate functions to summarize all 500 employees without grouping the records. `COUNT(*)` counts every row, while `COUNT(commission)` counts only commission values that are not `NULL`. I used `COALESCE` to treat missing commissions as zero when adding salary and commission.

**Code / query used:**
```sql
SELECT
    COUNT(*) AS total_employees,
    COUNT(commission) AS employees_with_commission,
    SUM(salary) AS monthly_payroll,
    AVG(salary) AS average_salary,
    MIN(hire_date) AS earliest_hire_date,
    MAX(hire_date) AS latest_hire_date,
    SUM(salary + COALESCE(commission, 0)) AS total_compensation
FROM employee;
```

**Query output:**

| Result | Value |
|---|---:|
| Total employees (`COUNT(*)`) | 500 |
| Employees with commission (`COUNT(commission)`) | 352 |
| Employees with NULL commission | 148 |
| Total monthly payroll (`SUM(salary)`) | 33,282,250.00 |
| Average salary (`AVG(salary)`) | 66,564.50 |
| Earliest hire date (`MIN(hire_date)`) | 2015-01-03 |
| Latest hire date (`MAX(hire_date)`) | 2026-09-14 |
| Total compensation with commission (`SUM`) | 35,387,750.00 |

**Explanation of the COUNT gap and COALESCE:**
`COUNT(*)` counts all 500 employee rows, but `COUNT(commission)` counts only the 352 rows with a non-NULL commission. The gap is 148 employees whose commission is `NULL`. `COALESCE(commission, 0)` changes each `NULL` commission to zero, so the salary-plus-commission expression can be included in the total for every employee.

The complete one-row query output is also saved in `task2_results.txt`.

**Reflection question:**
`COUNT(*)` counts every row in a table, including rows containing `NULL` values. `COUNT(column_name)` counts only rows where that specific column is not `NULL`.

## Task 3 — Grouping Data

**Approach / explanation:**
I used `GROUP BY department` to combine employees in the same department and calculate each department's headcount, average salary, and number of distinct job titles. I then used `GROUP BY department, job_title` to see the headcount for each job title within each department.

**Code / query used:**
```sql
-- 3.1 Summary per department
SELECT
    department,
    COUNT(*) AS headcount,
    AVG(salary) AS average_salary,
    COUNT(DISTINCT job_title) AS distinct_job_titles
FROM employee
GROUP BY department
ORDER BY department;

-- 3.2 Headcount per department and job title
SELECT
    department,
    job_title,
    COUNT(*) AS headcount
FROM employee
GROUP BY department, job_title
ORDER BY department, job_title;
```

**Query outputs:**

**3.1 Department summary**

| Department | Headcount | Average salary | Distinct job titles |
|---|---:|---:|---:|
| Engineering | 125 | 75,160.00 | 3 |
| Finance | 69 | 79,513.04 | 3 |
| HR | 50 | 62,610.00 | 3 |
| Sales | 144 | 71,799.65 | 3 |
| Support | 112 | 44,028.57 | 3 |

**3.2 Headcount by department and job title**

| Department | Job title | Headcount |
|---|---|---:|
| Engineering | DevOps Engineer | 42 |
| Engineering | QA Analyst | 39 |
| Engineering | Software Engineer | 44 |
| Finance | Accountant | 21 |
| Finance | Finance Manager | 24 |
| Finance | Financial Analyst | 24 |
| HR | HR Manager | 18 |
| HR | HR Specialist | 20 |
| HR | Recruiter | 12 |
| Sales | Account Manager | 50 |
| Sales | Sales Manager | 49 |
| Sales | Sales Representative | 45 |
| Support | Support Agent | 40 |
| Support | Support Lead | 29 |
| Support | Support Specialist | 43 |

The same outputs are saved in `task3_results.txt`.

**Reflection question:**
A grouped result represents multiple rows, so a non-grouped column may have several different values within one group. SQL requires that selected columns be grouped or aggregated so each result row has a clear value.

## Task 4 — Advanced Filtering with HAVING

**Approach / explanation:**
I used `HAVING` to filter the department groups based on their average salaries and headcounts. After inspecting the department averages, I chose **75,000** as the salary threshold because it separates the two departments with the highest average salaries from the other departments. For the second query, I filtered to active employees first, grouped them by department, and kept only groups with more than 50 employees.

**Code / query used:**
```sql
-- 4.1 Average salary greater than 75,000
SELECT
    department,
    AVG(salary) AS average_salary
FROM employee
GROUP BY department
HAVING AVG(salary) > 75000
ORDER BY average_salary DESC;

-- 4.2 More than 50 active employees per department
SELECT
    department,
    COUNT(*) AS active_headcount
FROM employee
WHERE status = 'Active'
GROUP BY department
HAVING COUNT(*) > 50
ORDER BY active_headcount DESC;
```

**Query outputs:**

**4.1 Average salary above 75,000**

| Department | Average salary |
|---|---:|
| Finance | 79,513.04 |
| Engineering | 75,160.00 |

`HAVING` is required because the condition checks an average calculated for each department group; `WHERE` filters individual employee rows before grouping.

**4.2 More than 50 active employees**

| Department | Active headcount |
|---|---:|
| Sales | 115 |
| Engineering | 104 |
| Support | 99 |
| Finance | 52 |

`WHERE status = 'Active'` selects the individual active employee rows first, while `HAVING COUNT(*) > 50` filters the department groups after their active headcounts have been calculated.

The complete outputs are also saved in `task4_results.txt`.

**Reflection question:**
We use `HAVING` because the average is an aggregate value calculated after grouping. `WHERE` works on individual rows before aggregation, while `HAVING` filters the grouped results.

## Self-Check

- [ ] All tasks committed with individual, meaningful commit messages
- [x] All deliverable files are organized inside `week08/`
- [x] This file is completed and named `answers.md`
- [ ] Repository URL pasted into Moodle (no files uploaded)

**Before submitting:** Replace the name, student ID, and GitHub username placeholders. Run the queries in MySQL Workbench or your MySQL client, capture your own screenshots if your instructor requires screenshots, commit each task separately, and paste your real repository URL into Moodle.
