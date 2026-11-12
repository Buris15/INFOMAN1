-- INFOMAN1 Week 11: Database Normalization
-- Run this script ONCE in phpMyAdmin / MySQL Workbench.
-- It creates infoman1_normalization and builds the schema through 1NF, 2NF, and 3NF.
-- To start over, first back up any work, then uncomment the DROP DATABASE line below.
-- DROP DATABASE IF EXISTS infoman1_normalization;

CREATE DATABASE IF NOT EXISTS infoman1_normalization;
USE infoman1_normalization;

-- ============================================================
-- SETUP: flawed source table (run once)
-- ============================================================
CREATE TABLE student_enrollment (
  student_id INT,
  student_name VARCHAR(100),
  enrolled_courses VARCHAR(200),
  course_id VARCHAR(10),
  course_title VARCHAR(100),
  dept_id VARCHAR(10),
  department_name VARCHAR(100),
  grade DECIMAL(4,2)
);

INSERT INTO student_enrollment VALUES
  (101, 'Ana Cruz', 'IT101, IT102', 'IT101', 'Database Systems', 'D01', 'Computing Studies', 1.50),
  (102, 'Ben Lim', 'IT101', 'IT101', 'Database Systems', 'D01', 'Computing Studies', 1.75),
  (101, 'Ana Cruz', 'IT101, IT102', 'IT102', 'Web Development', 'D01', 'Computing Studies', 1.25);

-- ============================================================
-- TASK 1: DIAGNOSE THE ANOMALIES (SELECT statements only)
-- ============================================================

-- 1A. Update anomaly: how many rows repeat the D01 department fact?
SELECT
  dept_id,
  department_name,
  COUNT(*) AS rows_carrying_department_fact
FROM student_enrollment
WHERE dept_id = 'D01'
GROUP BY dept_id, department_name;

-- Show the individual rows that would all need a department rename.
SELECT student_id, student_name, course_id, course_title,
       dept_id, department_name
FROM student_enrollment
WHERE dept_id = 'D01'
ORDER BY student_id, course_id;

-- 1B. Insert anomaly: show the proposed course-only fact and the missing student context.
-- This is intentionally a SELECT demonstration; it does not modify the source table.
SELECT
  'IT103' AS proposed_course_id,
  'Intro to Networks' AS proposed_course_title,
  'D01' AS proposed_dept_id,
  'Computing Studies' AS proposed_department_name,
  NULL AS student_id_required_by_this_row,
  NULL AS student_name_required_by_this_row,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM student_enrollment WHERE course_id = 'IT103'
    ) THEN 'IT103 is already present in the enrollment table'
    ELSE 'No IT103 row exists; the table has no separate course-only entity'
  END AS finding
FROM student_enrollment
LIMIT 1;

-- 1C. Delete anomaly: show Ana's only IT102 row and the sole stored copy of its course facts.
SELECT
  student_id,
  student_name,
  course_id,
  course_title,
  dept_id,
  department_name,
  (SELECT COUNT(*) FROM student_enrollment WHERE course_id = 'IT102')
    AS rows_storing_IT102_course_facts
FROM student_enrollment
WHERE student_id = 101 AND course_id = 'IT102';

-- ============================================================
-- TASK 2: FIRST NORMAL FORM (1NF)
-- One row per student-course pair; the multi-valued enrolled_courses field is removed.
-- ============================================================
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
  (student_id, student_name, course_id, course_title,
   dept_id, department_name, grade)
SELECT
  student_id, student_name, course_id, course_title,
  dept_id, department_name, grade
FROM student_enrollment;

-- Atomic-value evidence: each result row represents one student and one course.
SELECT student_id, student_name, course_id, course_title,
       dept_id, department_name, grade
FROM student_enrollment_1nf
ORDER BY student_id, course_id;

-- Confirm the row identity and row count.
SELECT COUNT(*) AS total_1nf_rows FROM student_enrollment_1nf;

-- ============================================================
-- TASK 3: SECOND NORMAL FORM (2NF)
-- Composite key in 1NF: (student_id, course_id).
-- Partial dependencies: student_id -> student_name;
-- course_id -> course_title, dept_id, department_name.
-- Full dependency: (student_id, course_id) -> grade.
-- ============================================================

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
  CONSTRAINT fk_enrollments_students
    FOREIGN KEY (student_id) REFERENCES students(student_id),
  CONSTRAINT fk_enrollments_courses_stage
    FOREIGN KEY (course_id) REFERENCES courses_stage(course_id)
);

INSERT INTO students (student_id, student_name)
SELECT DISTINCT student_id, student_name
FROM student_enrollment_1nf;

INSERT INTO courses_stage (course_id, course_title, dept_id, department_name)
SELECT DISTINCT course_id, course_title, dept_id, department_name
FROM student_enrollment_1nf;

INSERT INTO enrollments (student_id, course_id, grade)
SELECT student_id, course_id, grade
FROM student_enrollment_1nf;

-- 2NF reconstruction join: the split tables still reconstruct the same wide report.
SELECT
  s.student_id,
  s.student_name,
  c.course_id,
  c.course_title,
  c.dept_id,
  c.department_name,
  e.grade
FROM enrollments AS e
INNER JOIN students AS s ON e.student_id = s.student_id
INNER JOIN courses_stage AS c ON e.course_id = c.course_id
ORDER BY s.student_id, c.course_id;

-- ============================================================
-- TASK 4: THIRD NORMAL FORM (3NF)
-- Transitive dependency in the stage table: course_id -> dept_id -> department_name.
-- Move department_name to departments and keep dept_id as the course foreign key.
-- ============================================================

CREATE TABLE departments (
  dept_id VARCHAR(10) PRIMARY KEY,
  department_name VARCHAR(100) NOT NULL
);

INSERT INTO departments (dept_id, department_name)
SELECT DISTINCT dept_id, department_name
FROM courses_stage;

CREATE TABLE courses (
  course_id VARCHAR(10) PRIMARY KEY,
  course_title VARCHAR(100) NOT NULL,
  dept_id VARCHAR(10) NOT NULL,
  CONSTRAINT fk_courses_departments
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO courses (course_id, course_title, dept_id)
SELECT course_id, course_title, dept_id
FROM courses_stage;

-- Replace the intermediate course-stage foreign key with the final courses foreign key.
ALTER TABLE enrollments
  DROP FOREIGN KEY fk_enrollments_courses_stage;

ALTER TABLE enrollments
  ADD CONSTRAINT fk_enrollments_courses
  FOREIGN KEY (course_id) REFERENCES courses(course_id);

-- The intermediate table is no longer needed after the final tables are populated.
DROP TABLE courses_stage;

-- Four-table 3NF report: student, enrollment, course, and department facts are reconstructed.
SELECT
  s.student_id,
  s.student_name,
  c.course_id,
  c.course_title,
  d.dept_id,
  d.department_name,
  e.grade
FROM enrollments AS e
INNER JOIN students AS s ON e.student_id = s.student_id
INNER JOIN courses AS c ON e.course_id = c.course_id
INNER JOIN departments AS d ON c.dept_id = d.dept_id
ORDER BY s.student_id, c.course_id;

-- Final table row counts for a quick integrity check.
SELECT 'students' AS table_name, COUNT(*) AS total_rows FROM students
UNION ALL
SELECT 'courses', COUNT(*) FROM courses
UNION ALL
SELECT 'departments', COUNT(*) FROM departments
UNION ALL
SELECT 'enrollments', COUNT(*) FROM enrollments;

-- Final schema checks.
SHOW CREATE TABLE students;
SHOW CREATE TABLE courses;
SHOW CREATE TABLE departments;
SHOW CREATE TABLE enrollments;
