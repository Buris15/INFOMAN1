-- INFOMAN1 Week 10: Safe DML & Data Integrity Practical Test
-- Database: infoman1_bookstore
--
-- IMPORTANT:
-- 1. Run the SETUP/SEED section only once on a fresh database.
-- 2. Task 2 assumes the supplied seed runs once and Task 1 inserts
--    the Calculator and Compass once: Eraser = ID 5, Calculator = ID 6.
-- 3. The three invalid Task 4 INSERT statements are commented out.
--    Run each one separately after the constraints have been added.

-- =========================================================
-- SETUP: supplied database and seed data (run once)
-- =========================================================

CREATE DATABASE IF NOT EXISTS infoman1_bookstore;
USE infoman1_bookstore;

CREATE TABLE products (
  product_id INT PRIMARY KEY AUTO_INCREMENT,
  product_name VARCHAR(100),
  sku VARCHAR(30),
  price DECIMAL(10,2),
  stock_quantity INT,
  status VARCHAR(20)
);

CREATE TABLE sales (
  sale_id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT,
  sale_date DATE,
  quantity INT,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE employees (
  employee_id INT PRIMARY KEY,
  employee_name VARCHAR(100) NOT NULL,
  manager_id INT
);

CREATE TABLE colors (
  color_name VARCHAR(30) PRIMARY KEY
);

CREATE TABLE sizes (
  size_name VARCHAR(10) PRIMARY KEY
);

INSERT INTO products (product_name, sku, price, stock_quantity, status) VALUES
  ('Notebook', 'NB-001', 45.00, 100, 'Active'),
  ('Ballpen', 'BP-001', 15.00, 250, 'Active'),
  ('USB Drive', 'USB-001', 350.00, 30, 'Active'),
  ('Ruler', 'RL-001', 25.00, 80, 'Active'),
  ('Eraser', 'ER-001', 10.00, 200, 'Active');

INSERT INTO sales (product_id, sale_date, quantity) VALUES
  (1, '2026-08-10', 5),
  (2, '2026-08-11', 10);

INSERT INTO employees VALUES
  (1, 'Lea Ramos', NULL),
  (2, 'Carlo Reyes', 1),
  (3, 'Dana Cruz', 1);

INSERT INTO colors VALUES ('Red'), ('Blue'), ('Green');
INSERT INTO sizes VALUES ('S'), ('M'), ('L');

-- =========================================================
-- TASK 1: Safe INSERT
-- =========================================================

INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Scientific Calculator', 'CALC-SCI-001', 850.00, 20, 'Active');

SELECT product_id, product_name, sku, price, stock_quantity, status
FROM products
WHERE sku = 'CALC-SCI-001';

INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Compass', 'CMP-001', 120.00, 50, 'Active');

SELECT product_id, product_name, sku, price, stock_quantity, status
FROM products
WHERE sku = 'CMP-001';

-- =========================================================
-- TASK 2: UPDATE & DELETE Without Collateral Damage
-- =========================================================

-- Preview the Calculator before updating it.
SELECT product_id, product_name, sku, price
FROM products
WHERE product_id = 6;

UPDATE products
SET price = 875.00
WHERE product_id = 6;

SELECT product_id, product_name, sku, price
FROM products
WHERE product_id = 6;

-- Preview the Eraser before deleting it.
SELECT product_id, product_name, sku, price
FROM products
WHERE product_id = 5;

DELETE FROM products
WHERE product_id = 5;

-- Expected: zero rows.
SELECT product_id, product_name, sku, price
FROM products
WHERE product_id = 5;

-- =========================================================
-- TASK 3: Self Join & Cross Join
-- =========================================================

SELECT
  e.employee_id,
  e.employee_name AS employee_name,
  m.employee_name AS manager_name
FROM employees AS e
LEFT JOIN employees AS m
  ON e.manager_id = m.employee_id
ORDER BY e.employee_id;

SELECT
  c.color_name,
  s.size_name
FROM colors AS c
CROSS JOIN sizes AS s
ORDER BY c.color_name, s.size_name;

SELECT COUNT(*) AS total_color_size_pairs
FROM colors AS c
CROSS JOIN sizes AS s;

-- =========================================================
-- TASK 4: Constraints & Table Evolution
-- =========================================================

-- Create a students-style practice table, then add contact_number.
CREATE TABLE students_practice (
  student_id INT PRIMARY KEY,
  student_name VARCHAR(100) NOT NULL
);

ALTER TABLE students_practice
ADD COLUMN contact_number VARCHAR(20);

-- Check existing product data before adding constraints.
-- These checks should return no rows / no duplicate SKU groups.
SELECT product_id, product_name
FROM products
WHERE product_name IS NULL;

SELECT sku, COUNT(*) AS sku_count
FROM products
GROUP BY sku
HAVING COUNT(*) > 1;

SELECT product_id, product_name, sku, price
FROM products
WHERE price <= 0;

-- Add the three constraints.
ALTER TABLE products
MODIFY COLUMN product_name VARCHAR(100) NOT NULL;

ALTER TABLE products
ADD CONSTRAINT uq_products_sku UNIQUE (sku);

ALTER TABLE products
ADD CONSTRAINT chk_products_price CHECK (price > 0);

SELECT VERSION() AS mysql_version;
SHOW CREATE TABLE products;

-- Valid NOT NULL test.
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('NOT NULL valid test', 'TEST-NN-001', 10.00, 1, 'Active');

SELECT product_id, product_name, sku
FROM products
WHERE sku = 'TEST-NN-001';

-- Valid UNIQUE test.
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('UNIQUE valid test', 'TEST-UNIQUE-001', 10.00, 1, 'Active');

SELECT product_id, product_name, sku
FROM products
WHERE sku = 'TEST-UNIQUE-001';

-- Valid CHECK test.
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('CHECK valid test', 'TEST-CHECK-001', 10.00, 1, 'Active');

SELECT product_id, product_name, sku, price
FROM products
WHERE sku = 'TEST-CHECK-001';

-- ---------------------------------------------------------
-- EXPECTED-REJECTION TESTS
-- Run ONE statement at a time after the constraints are added.
-- Uncomment the relevant INSERT only when testing it.
-- ---------------------------------------------------------

-- NOT NULL violation.
-- INSERT INTO products (product_name, sku, price, stock_quantity, status)
-- VALUES (NULL, 'TEST-NN-BAD', 10.00, 1, 'Active');

-- UNIQUE violation: NB-001 already belongs to Notebook.
-- INSERT INTO products (product_name, sku, price, stock_quantity, status)
-- VALUES ('Duplicate SKU test', 'NB-001', 99.00, 1, 'Active');

-- CHECK violation: price must be greater than zero.
-- INSERT INTO products (product_name, sku, price, stock_quantity, status)
-- VALUES ('Zero price test', 'TEST-CHECK-BAD', 0.00, 1, 'Active');

-- Final inspection: expected 9 rows after the three valid test inserts.
SELECT product_id, product_name, sku, price, stock_quantity, status
FROM products
ORDER BY product_id;

SELECT COUNT(*) AS final_product_count
FROM products;
