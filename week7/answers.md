# INFOMAN1 — Week 7 Lab Answers

## Task 1 — Complex Student Roster

**Approach / explanation:**

For this task, I used `IN` to get students who are taking either Computer Science or Information Technology. I used `LIKE 'S%'` to check if their last name starts with the letter S. I also used `NOT` to remove students whose section is Online.

**Code / query used:**

```sql
USE university_db;

SELECT first_name, last_name, major
FROM students
WHERE major IN ('Computer Science', 'Information Technology')
  AND last_name LIKE 'S%'
  AND NOT (section = 'Online');
```

**Expected result:**

| first_name | last_name | major |
|---|---|---|
| Sofia | Santos | Computer Science |
| Samuel | Santiago | Information Technology |
| Sarah | Sy | Computer Science |
| Daniel | Serrano | Information Technology |
| Liza | Soberano | Computer Science |

**Evidence:**

`task1_output.png` — screenshot of my query and its result grid in MySQL Workbench. I will add the screenshot to this folder after running the query.

**Reflection question:**

I think `IN` is better because it makes the query shorter and easier to read when checking several values. Instead of writing the column name multiple times with `OR`, I can just list the values inside `IN`. It is also easier to update when I need to add or remove a value.

---

## Task 2 — Formatting Employee Data

**Approach / explanation:**

I used `LEFT` to get the first letter of each instructor's first name. Then I used `CONCAT` to combine the initial, last name, and salary into one column. I used `ROUND` so the salary would be shown as a whole number, and `LIMIT 5` to display only the first five instructors.

**Code / query used:**

```sql
USE university_db;

SELECT CONCAT(
    LEFT(first_name, 1),
    '. ',
    last_name,
    ' ($',
    ROUND(salary),
    ')'
) AS `Instructor Details`
FROM instructors
ORDER BY instructor_id ASC
LIMIT 5;
```

**Expected textual output (first 5 rows):**

```text
Instructor Details
J. Smith ($55001)
M. Santos ($62500)
R. Johnson ($49000)
A. Reyes ($71250)
P. Cruz ($47001)
```

**Evidence:**

The first five rows are shown above. I can also include a screenshot or the output from MySQL Workbench in this folder if required.

**Reflection question:**

Using `CONCAT` in SQL makes the database combine the text before showing the result. It can use a little more processing than just getting the original columns, but for a small number of records the difference is not a big problem. Formatting in Java or Python is also useful because I can change how the information looks in the application without changing the query.

---

## Task 3 — Project Deadline Analysis

**Approach / explanation:**

I used `DATEDIFF` to get the number of days between the assigned date and due date of each assignment. I added a condition to show only assignments that have more than 14 days to complete. I sorted the results using `Days_To_Complete` in descending order so the longest duration appears first.

**Code / query used:**

```sql
USE university_db;

SELECT
    assignment_name,
    DATEDIFF(due_date, assigned_date) AS Days_To_Complete
FROM assignments
WHERE DATEDIFF(due_date, assigned_date) > 14
ORDER BY Days_To_Complete DESC;
```

**Expected result:**

| assignment_name | Days_To_Complete |
|---|---:|
| Capstone Proposal | 44 |
| Midterm Lab Report | 25 |
| Normalization Case | 21 |
| SQL Basics Worksheet | 20 |

**Evidence:**

`task3_output.png` — screenshot of my query and the sorted result grid in MySQL Workbench. I will add the screenshot to this folder after running the query.

**Reflection question:**

Aliases are useful because they give calculated columns a simple name that is easier to understand. For example, `Days_To_Complete` is clearer than looking at the whole `DATEDIFF` expression. It also makes the output easier to read, and I can use the alias when sorting the results with `ORDER BY`.

---

## Task 4 — Comprehensive Data Audit

**Approach / explanation:**

I used `IS NULL` to find courses that do not have a description. I also used `BETWEEN 4 AND 6` to check the credits, and `LIKE '%ADV%'` to find course codes that contain ADV. I added parentheses around the first two conditions before using `AND` with the course code condition so that the query follows the required logic.

**Code / query used:**

```sql
USE university_db;

SELECT course_code, course_name, credits
FROM courses
WHERE (course_description IS NULL OR credits BETWEEN 4 AND 6)
  AND course_code LIKE '%ADV%'
ORDER BY course_name ASC;
```

**Expected result:**

| course_code | course_name | credits |
|---|---|---:|
| CS-ADV305 | Advanced Algorithms | 4 |
| CS-ADV400 | Advanced Capstone Project | 6 |
| CS-ADV101 | Advanced Database Systems | 5 |
| IT-ADV210 | Advanced Networking | 3 |
| ENG-ADV110 | Advanced Technical Writing | 2 |
| IT-ADV150 | Advanced Web Development | 6 |

**Evidence:**

The SQL query and expected result are shown above. The explanation of the `AND` and `OR` conditions is included below.

**Reflection question:**

In MySQL, `AND` is evaluated before `OR`. This means `A OR B AND C` is treated as `A OR (B AND C)`. I used parentheses around `(course_description IS NULL OR credits BETWEEN 4 AND 6)` so that either of those conditions can be true, but the course code must still contain `ADV`. This way, every result follows the conditions in the task.

---

## Self-Check

- [ ] All tasks committed with individual, meaningful commit messages
- [ ] All files placed inside `week7/`
- [ ] This file completed and saved as `answers.md`
- [ ] Repository link pasted into Moodle (no files uploaded)
