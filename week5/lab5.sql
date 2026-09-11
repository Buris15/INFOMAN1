USE infoman1_vetclinic;

-- ==========================================
-- LAB 5: SELECT WITH CONDITIONS
-- ==========================================


-- ==========================================
-- Task 1: Basic SELECT Statements
-- ==========================================

-- 1A. Return every column and every row from pet
SELECT *
FROM pet;

-- 1B. Return only name and species
SELECT name, species
FROM pet;


-- ==========================================
-- Task 2: Filtering with Equality
-- ==========================================

-- Return the name and species of every Dog
SELECT name, species
FROM pet
WHERE species = 'Dog';


-- ==========================================
-- Task 3: Filtering with Relational Operators
-- ==========================================

-- 3A. Return pets born after January 1, 2020
SELECT name, species, date_of_birth
FROM pet
WHERE date_of_birth > '2020-01-01';

-- 3B. Return appointments after January 1, 2026
SELECT appointment_id, pet_id, vet_id, appointment_date, reason
FROM appointment
WHERE appointment_date > '2026-01-01';


-- ==========================================
-- Task 4: Combine and Debug
-- ==========================================

-- 4A. Working query
SELECT name, species
FROM pet
WHERE species = 'Dog';

-- 4B. Deliberately broken query
-- Missing quotation marks around Dog
SELECT name, species
FROM pet
WHERE species = Dog;