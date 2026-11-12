# INFOMAN1 — Week 11 Lab Answers

Name: **[Your Name]**  
Student ID: **[Your Student ID]**  
GitHub repo: https://github.com/<STUDENT_GITHUB_USERNAME>/infoman1  
Date submitted: **[Submission Date]**

## Task 1 — Diagnose the Anomalies

**Approach / explanation:**

I checked the original `student_enrollment` table using SELECT queries so I could show the repeated department information, the missing course-only record, and the course information stored only with Ana's enrollment. I did not change the source data in this task. The results show that the table mixes student, course, and department information in one enrollment record.

**Code / query used (if applicable):**

```sql
SELECT dept_id, department_name, COUNT(*) AS rows_carrying_department_fact
FROM student_enrollment
WHERE dept_id = 'D01'
GROUP BY dept_id, department_name;

SELECT student_id, student_name, course_id, course_title, dept_id, department_name
FROM student_enrollment
WHERE dept_id = 'D01'
ORDER BY student_id, course_id;

SELECT 'IT103' AS proposed_course_id,
       'Intro to Networks' AS proposed_course_title,
       'D01' AS proposed_dept_id,
       NULL AS student_id_required_by_this_row,
       NULL AS student_name_required_by_this_row,
       'No separate course-only entity exists in this table' AS finding
FROM student_enrollment
LIMIT 1;

SELECT student_id, student_name, course_id, course_title, dept_id, department_name,
       (SELECT COUNT(*) FROM student_enrollment WHERE course_id = 'IT102')
         AS rows_storing_IT102_course_facts
FROM student_enrollment
WHERE student_id = 101 AND course_id = 'IT102';
```

**Evidence (screenshot filename, output, or file reference in this folder):**

See `expected_outputs.md`, Task 1. In the original data, D01 appears in **3 rows**. The IT103 demonstration shows that a course-only fact has no student information to pair with it. The Ana/IT102 query returns **1 row**, which is the only stored row containing the IT102 course facts. Add your own phpMyAdmin screenshots after running `week11.sql`.

**Reflection question:**

The insert anomaly surprised me most because a course should be recordable even before a student enrolls in it. All three anomalies come from storing facts about different entities in one table instead of giving students, courses, departments, and enrollments their own tables.

## Task 2 — Reach First Normal Form

**Approach / explanation:**

I created `student_enrollment_1nf` with one record for every student-course pair and removed the multi-valued `enrolled_courses` column. I used `(student_id, course_id)` as the composite primary key because the same student can take different courses and the same course can have different students. The SELECT result shows one course ID and one grade per row.

**Code / query used (if applicable):**

```sql
CREATE TABLE student_enrollment_1nf (
  student_id INT NOT NULL,
  student_name VARCHAR(100) NOT NULL,
  course_id VARCHAR(10) NOT NULL,
  course_title VARCHAR(100) NOT NULL,
  dept_id VARCHAR(10) NOT NULL,
  department_name VARCHAR(100) NOT NULL,
  grade DECIMAL(4,2),
  PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_enrollment_1nf
  (student_id, student_name, course_id, course_title, dept_id, department_name, grade)
SELECT student_id, student_name, course_id, course_title, dept_id, department_name, grade
FROM student_enrollment;

SELECT student_id, student_name, course_id, course_title,
       dept_id, department_name, grade
FROM student_enrollment_1nf
ORDER BY student_id, course_id;
```

**Evidence (screenshot filename, output, or file reference in this folder):**

See `expected_outputs.md`, Task 2. The SELECT query should return **3 rows**. Each row contains one student-course pair. Some redundancy remains because Ana's name repeats and the IT101 course and department facts appear in more than one enrollment row. Add your own phpMyAdmin screenshot after running the script.

**Reflection question:**

Student names still repeat because a student can appear in more than one student-course row, even after every value becomes atomic. The next step, 2NF, removes attributes that depend on only part of the composite key by moving student details into a separate students table.

## Task 3 — Reach Second Normal Form

**Approach / explanation:**

The composite key in the 1NF table is `(student_id, course_id)`. I identified the partial dependencies `student_id → student_name` and `course_id → course_title, dept_id, department_name`, while `grade` depends on the full student-course key. I split the student facts, course facts, and enrollment facts into separate tables, then used a JOIN to check that the report could still be reconstructed.

**Code / query used (if applicable):**

```sql
CREATE TABLE students (
  student_id INT PRIMARY KEY,
  student_name VARCHAR(100) NOT NULL
);

CREATE TABLE courses_stage (
  course_id VARCHAR(10) PRIMARY KEY,
  course_title VARCHAR(100) NOT NULL,
  dept_id VARCHAR(10) NOT NULL,
  department_name VARCHAR(100) NOT NULL
);

CREATE TABLE enrollments (
  student_id INT NOT NULL,
  course_id VARCHAR(10) NOT NULL,
  grade DECIMAL(4,2),
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (course_id) REFERENCES courses_stage(course_id)
);

SELECT s.student_id, s.student_name, c.course_id, c.course_title,
       c.dept_id, c.department_name, e.grade
FROM enrollments AS e
INNER JOIN students AS s ON e.student_id = s.student_id
INNER JOIN courses_stage AS c ON e.course_id = c.course_id
ORDER BY s.student_id, c.course_id;
```

**Evidence (screenshot filename, output, or file reference in this folder):**

See `expected_outputs.md`, Task 3. The reconstruction JOIN should return the same **3 enrollment rows** and grades as the 1NF table. `grade` stays in `enrollments` because its value is determined by the combination of a particular student and a particular course, not by either key column alone. Add your own phpMyAdmin screenshot after running the script.

**Reflection question:**

The student name depends only on `student_id`, so it can be found without knowing the course. A grade is different because the same student can receive different grades in different courses, and a course can have different grades for different students; therefore, the full pair is needed.

## Task 4 — Reach Third Normal Form

**Approach / explanation:**

The transitive dependency in the course-stage data is `course_id → dept_id → department_name`. I moved the department name into a `departments` table and kept `dept_id` in `courses` as a foreign key. I then connected the enrollments table to the final courses table and used a four-table JOIN to rebuild the complete report.

**Code / query used (if applicable):**

```sql
CREATE TABLE departments (
  dept_id VARCHAR(10) PRIMARY KEY,
  department_name VARCHAR(100) NOT NULL
);

CREATE TABLE courses (
  course_id VARCHAR(10) PRIMARY KEY,
  course_title VARCHAR(100) NOT NULL,
  dept_id VARCHAR(10) NOT NULL,
  FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

ALTER TABLE enrollments
  DROP FOREIGN KEY fk_enrollments_courses_stage;

ALTER TABLE enrollments
  ADD CONSTRAINT fk_enrollments_courses
  FOREIGN KEY (course_id) REFERENCES courses(course_id);

SELECT s.student_id, s.student_name, c.course_id, c.course_title,
       d.dept_id, d.department_name, e.grade
FROM enrollments AS e
INNER JOIN students AS s ON e.student_id = s.student_id
INNER JOIN courses AS c ON e.course_id = c.course_id
INNER JOIN departments AS d ON c.dept_id = d.dept_id
ORDER BY s.student_id, c.course_id;
```

**Normalization decision path:**

| Final table | Multi-valued values? | Partial dependency? | Transitive dependency? | Verdict |
|---|---|---|---|---|
| `students` | No | No; single-column key | No | 3NF |
| `courses` | No | No; single-column key | No; department name is stored in `departments` | 3NF |
| `departments` | No | No; single-column key | No | 3NF |
| `enrollments` | No | No; `grade` depends on the full composite key | No | 3NF |

**Evidence (screenshot filename, output, or file reference in this folder):**

See `expected_outputs.md`, Task 4. The final four-table JOIN should return **3 rows** with the student name, course title, department name, and grade. The final table counts should be 2 students, 2 courses, 1 department, and 3 enrollments. Add your own phpMyAdmin screenshot after running the script.

**Reflection question:**

The department name is indirectly dependent on `course_id` because the course determines `dept_id`, and `dept_id` determines the department name. The final JOIN proves that the split preserved the relationships because all three original student-course-grade records can still be displayed with their matching course and department facts.

## Task 5 — Reflection

**Approach / explanation:**

I compared the problems in the original table with the final four-table design and considered when a system might choose faster reporting over fully normalized storage.

**Code / query used (if applicable):**

No additional SQL is required for this reflection. The example is based on the normalization steps in Tasks 1–4.

**Evidence (screenshot filename, output, or file reference in this folder):**

The completed reflection is written below. Add a screenshot only if your instructor specifically requires one for this task.

**Reflection (150–200 words):**

For a campus enrollment system, I would normally use 3NF for the main database because student details, course details, department details, and grades should be stored in the tables where they belong. In Task 4, I separated `department_name` from `courses` because a department name depends on `dept_id`, not directly on each course. This avoids updating the same department name in several course records. However, I understand that some repetition can be useful in a reporting database or a prepared summary table when the school needs faster reports. I would only do that deliberately and make sure the repeated data can be refreshed from the normalized source. One mistake I noticed while working through the split was that the course-stage table still contained `department_name` after the departments table was introduced. The symptom would be having two places to update when a department name changes. I fixed the design by keeping only `dept_id` in the final `courses` table and joining to `departments` when the department name is needed. This keeps the final relationships clear and avoids that repeated department fact.

## Self-Check

- [ ] All tasks committed with individual, meaningful commit messages
- [ ] All files placed inside `week11/`
- [ ] This file completed and saved as `answers.md`
- [ ] Actual phpMyAdmin output/screenshots added to the repository
- [ ] Repository link pasted into Moodle (no files uploaded)
