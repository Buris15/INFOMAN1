# INFOMAN1 Week 11 — Expected Outputs

These are the expected result sets from the supplied seed data and `week11.sql`. They are reference outputs, not screenshots or proof of execution on your local MySQL/MariaDB server. Run the SQL in XAMPP/phpMyAdmin and capture your own results for submission.

## Task 1 — Anomalies

### Update anomaly count

| dept_id | department_name | rows_carrying_department_fact |
|---|---|---:|
| D01 | Computing Studies | 3 |

The department name is repeated in all three source rows, so a rename would need to update all three.

### Insert anomaly proposal

| proposed_course_id | proposed_course_title | proposed_dept_id | proposed_department_name | student_id_required_by_this_row | student_name_required_by_this_row | finding |
|---|---|---|---|---|---|---|
| IT103 | Intro to Networks | D01 | Computing Studies | NULL | NULL | No IT103 row exists; the table has no separate course-only entity |

This SELECT only demonstrates the missing student context. It does not execute an INSERT. The source table has nullable columns, so SQL could technically store NULL student fields, but that would be an incomplete enrollment-style row rather than a properly separated course record.

### Delete anomaly

| student_id | student_name | course_id | course_title | dept_id | department_name | rows_storing_IT102_course_facts |
|---:|---|---|---|---|---|---:|
| 101 | Ana Cruz | IT102 | Web Development | D01 | Computing Studies | 1 |

Deleting Ana's IT102 enrollment row from the flawed table would also remove the only stored row containing the IT102 course facts.

## Task 2 — First Normal Form

Expected `student_enrollment_1nf` result:

| student_id | student_name | course_id | course_title | dept_id | department_name | grade |
|---:|---|---|---|---|---|---:|
| 101 | Ana Cruz | IT101 | Database Systems | D01 | Computing Studies | 1.50 |
| 101 | Ana Cruz | IT102 | Web Development | D01 | Computing Studies | 1.25 |
| 102 | Ben Lim | IT101 | Database Systems | D01 | Computing Studies | 1.75 |

Expected `total_1nf_rows`: **3**. The `enrolled_courses` multi-valued column is not present in the 1NF table. Every row contains one student-course pair.

## Task 3 — Second Normal Form

Expected reconstruction JOIN result:

| student_id | student_name | course_id | course_title | dept_id | department_name | grade |
|---:|---|---|---|---|---|---:|
| 101 | Ana Cruz | IT101 | Database Systems | D01 | Computing Studies | 1.50 |
| 101 | Ana Cruz | IT102 | Web Development | D01 | Computing Studies | 1.25 |
| 102 | Ben Lim | IT101 | Database Systems | D01 | Computing Studies | 1.75 |

Expected row count: **3**.

Functional dependencies identified from the provided rows/design:

- `student_id -> student_name`
- `course_id -> course_title, dept_id, department_name`
- `dept_id -> department_name`
- `(student_id, course_id) -> grade`

`grade` belongs in `enrollments` because it depends on the complete student-course combination.

## Task 4 — Third Normal Form

Expected final four-table JOIN result:

| student_id | student_name | course_id | course_title | dept_id | department_name | grade |
|---:|---|---|---|---|---|---:|
| 101 | Ana Cruz | IT101 | Database Systems | D01 | Computing Studies | 1.50 |
| 101 | Ana Cruz | IT102 | Web Development | D01 | Computing Studies | 1.25 |
| 102 | Ben Lim | IT101 | Database Systems | D01 | Computing Studies | 1.75 |

Expected row count: **3**.

Expected final table counts:

| table_name | total_rows |
|---|---:|
| students | 2 |
| courses | 2 |
| departments | 1 |
| enrollments | 3 |

Final decision-path verdicts:

| Table | 1NF: atomic? | 2NF: no partial dependency? | 3NF: no transitive non-key dependency? |
|---|---|---|---|
| students | Yes | Yes | Yes |
| courses | Yes | Yes | Yes |
| departments | Yes | Yes | Yes |
| enrollments | Yes | Yes; grade depends on the full composite key | Yes |

## Run notes

- Run `week11.sql` once on a fresh lab database.
- The `IT103` query is a SELECT demonstration only; it intentionally does not modify the original table.
- The course-stage table is an intermediate 2NF structure. The script replaces its foreign-key link with the final `courses` foreign key and then drops the stage table.
- Actual MySQL/MariaDB output wording may vary by server version, but the listed rows and counts should match the seed data.
