# INFOMAN1 — Week 10 Lab Answers

Name: Adrian D. Lacsamana  
Student ID: **2510955**  
GitHub repo: https://github.com/Buris15/infoman1  
Date submitted: November 12, 2026

## Task 1 — Safe INSERT

**Approach / explanation:**

I inserted the Scientific Calculator and Compass by naming the columns in each INSERT statement. After each insert, I used a SELECT query with the product's SKU to check that the correct record was saved. I used the SKU for the confirmation query so I could identify the product I had just added.

**Code / query used (if applicable):**

```sql
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
```

A rejected example is an INSERT that uses `sku = 'NB-001'` after the UNIQUE constraint is added in Task 4. That SKU already belongs to Notebook, so the database rejects the duplicate value.

**Evidence (screenshot filename, output, or file reference in this folder):**

The expected Calculator and Compass result rows are listed in `expected_outputs.md`. I will add my phpMyAdmin screenshot here after running the statements on my local MySQL/MariaDB server.

**Reflection question:**

Listing the target columns makes an INSERT safer because I can see which value goes into each column instead of depending on the table's column order. When I omit a column, the database uses its declared default. An AUTO_INCREMENT ID is generated automatically, while an omitted nullable column with no other default can receive NULL.

## Task 2 — UPDATE & DELETE Without Collateral Damage

**Approach / explanation:**

Before changing the data, I used SELECT with the same WHERE condition that I planned to use in the UPDATE or DELETE. I used `product_id` because it is the primary key and identifies one product record. After each change, I ran another SELECT with that condition to check the result.

**Code / query used (if applicable):**

```sql
-- Preview the Calculator before updating it
SELECT product_id, product_name, sku, price
FROM products
WHERE product_id = 6;

-- Change only the Calculator price
UPDATE products
SET price = 875.00
WHERE product_id = 6;

-- Verify the updated Calculator
SELECT product_id, product_name, sku, price
FROM products
WHERE product_id = 6;

-- Preview the Eraser before deleting it
SELECT product_id, product_name, sku, price
FROM products
WHERE product_id = 5;

-- Delete only the Eraser test row
DELETE FROM products
WHERE product_id = 5;

-- Verify that the Eraser is no longer in the table
SELECT product_id, product_name, sku, price
FROM products
WHERE product_id = 5;
```

**Evidence (screenshot filename, output, or file reference in this folder):**

The expected before-and-after results are in `expected_outputs.md`. I will add the actual phpMyAdmin preview and verification screenshots after running the queries locally.

**Reflection question:**

Without its WHERE clause, the UPDATE would change the price of every product. The DELETE would attempt to delete every product, and the foreign key in `sales` would prevent deleting products that still have sales records. A primary key is safer than a name because names can be repeated, while each `product_id` identifies a specific row.

## Task 3 — Self Join & Cross Join

**Approach / explanation:**

I used the employees table twice in the self join: `e` represents the employee and `m` represents the manager. I used LEFT JOIN so employees without a manager would still appear in the result. For the CROSS JOIN, I combined the three colors with the three sizes to display every possible pair.

**Code / query used (if applicable):**

```sql
-- Employee and manager names
SELECT
  e.employee_id,
  e.employee_name AS employee_name,
  m.employee_name AS manager_name
FROM employees AS e
LEFT JOIN employees AS m
  ON e.manager_id = m.employee_id
ORDER BY e.employee_id;

-- Every color-size combination
SELECT
  c.color_name,
  s.size_name
FROM colors AS c
CROSS JOIN sizes AS s
ORDER BY c.color_name, s.size_name;

-- Count all color-size combinations
SELECT COUNT(*) AS total_color_size_pairs
FROM colors AS c
CROSS JOIN sizes AS s;
```

The self join needs two aliases because the same table is being used for two different roles. LEFT JOIN keeps Lea in the result even though her manager_id is NULL. A bookstore can use CROSS JOIN to generate notebook variants in every available color and size. It should not happen accidentally because a missing join condition can multiply rows and return combinations that were not intended.

**Evidence (screenshot filename, output, or file reference in this folder):**

The expected self-join result and all nine color-size pairs are listed in `expected_outputs.md`. I will add the actual query-result screenshots from phpMyAdmin after running them.

**Reflection question:**

The aliases let me identify which employee row is being compared with which manager row. LEFT JOIN keeps employees who do not have a manager. CROSS JOIN is useful when I really need every possible combination, such as product variants, but it should not be used as a replacement for a missing ON condition in an ordinary join.

## Task 4 — Constraints & Table Evolution

**Approach / explanation:**

I first created a small students-style practice table and added a `contact_number` column using ALTER TABLE. Before adding the product constraints, I included SELECT queries to check for NULL product names, duplicate SKUs, and prices that are zero or below. After checking the existing data, I added NOT NULL, UNIQUE, and CHECK constraints, then included valid and invalid INSERT examples for each rule.

**Code / query used (if applicable):**

```sql
-- Create a students-style practice table
CREATE TABLE students_practice (
  student_id INT PRIMARY KEY,
  student_name VARCHAR(100) NOT NULL
);

-- Add the contact_number column
ALTER TABLE students_practice
ADD COLUMN contact_number VARCHAR(20);

-- Check existing product data before adding constraints
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

-- Require every product to have a name
ALTER TABLE products
MODIFY COLUMN product_name VARCHAR(100) NOT NULL;

-- Do not allow duplicate SKUs
ALTER TABLE products
ADD CONSTRAINT uq_products_sku UNIQUE (sku);

-- Require a price greater than zero
ALTER TABLE products
ADD CONSTRAINT chk_products_price CHECK (price > 0);

-- Check the database version and the table definition
SELECT VERSION() AS mysql_version;
SHOW CREATE TABLE products;
```

Valid writes:

```sql
-- Valid NOT NULL test
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('NOT NULL valid test', 'TEST-NN-001', 10.00, 1, 'Active');

-- Valid UNIQUE test
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('UNIQUE valid test', 'TEST-UNIQUE-001', 10.00, 1, 'Active');

-- Valid CHECK test
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('CHECK valid test', 'TEST-CHECK-001', 10.00, 1, 'Active');
```

Invalid writes (I run each one separately after adding the constraints):

```sql
-- NOT NULL violation
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES (NULL, 'TEST-NN-BAD', 10.00, 1, 'Active');

-- UNIQUE violation: NB-001 already belongs to Notebook
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Duplicate SKU test', 'NB-001', 99.00, 1, 'Active');

-- CHECK violation: zero is not greater than zero
INSERT INTO products (product_name, sku, price, stock_quantity, status)
VALUES ('Zero price test', 'TEST-CHECK-BAD', 0.00, 1, 'Active');
```

**MySQL syntax caveat and test:**

MySQL enforces CHECK constraints starting with version 8.0.16. Older MySQL versions may accept the syntax without enforcing it. I included `SELECT VERSION()` to identify the server version and `SHOW CREATE TABLE products` to inspect the constraints. I then run each invalid INSERT separately; each should return an error and should not add a row. Since XAMPP may use MariaDB, I also check the actual server version and confirm that the zero-price test is rejected instead of assuming that the CHECK constraint is enforced.

**Evidence (screenshot filename, output, or file reference in this folder):**

The expected valid rows and the three rejection reasons are listed in `expected_outputs.md`. I will add screenshots of SHOW CREATE TABLE and the actual valid and rejected INSERT results after testing on my local server. I will also record the version returned by `SELECT VERSION()`.

**Reflection question:**

Constraints prevent new records from breaking a rule, but they do not automatically repair records that already exist. Before adding NOT NULL, I need to check for existing NULL product names and correct or remove them. I should also check for duplicate SKUs and invalid prices before adding UNIQUE and CHECK so that the ALTER TABLE statements can succeed.

## Task 5 — Reflection

**Approach / explanation:**

I compared the checks that help a cashier while entering a product with the constraints that protect the database. I used the positive-price and unique-SKU rules from Task 4 as examples and included an issue I noticed while reviewing my Task 2 query conditions.

**Code / query used (if applicable):**

Not applicable. This task is a written reflection.

**Evidence (screenshot filename, output, or file reference in this folder):**

The written reflection is included below and is within the required 150–200 word range.

**Reflection question / 150–200 word reflection:**

For a campus bookstore, I would use application-level checks to guide the cashier and database constraints to protect records, even when data comes from another screen or script. The form can check that a price is greater than zero and show a clear message before submission. The database should also enforce `CHECK (price > 0)` because a direct SQL command or another application could bypass the form. The `UNIQUE (sku)` rule is also important because it prevents two products from receiving the same stock code, even if two cashiers submit at nearly the same time. I would use application validation for quick feedback and database constraints as the final protection. One issue I noticed in my Task 2 script is that it relies on fixed product IDs and assumes the seed data is inserted only once. If I rerun the seed or add rows first, ID 6 might not belong to the Calculator. The symptom would be the preview showing the wrong product before the update. I would fix this by starting with a fresh lab database, running the seed once, and checking the ID, product name, and SKU in the preview before I update or delete a row.

## Self-Check

- [ ] I committed the tasks with individual, meaningful commit messages.
- [x] The lab files are placed inside `week10/`.
- [x] This answer file is named `answers.md`.
- [ ] I added my actual MySQL/MariaDB screenshots and recorded the server version.
- [ ] I replaced the student ID and GitHub username placeholders.
- [ ] I pasted my repository link into Moodle (no files uploaded).
