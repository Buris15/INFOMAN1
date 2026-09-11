-- ==========================================
-- Task 1: Create the Database
-- ==========================================
CREATE DATABASE infoman1_vetclinic;
SHOW DATABASES;
USE infoman1_vetclinic;

-- ==========================================
-- Task 2: Create the Core Tables
-- ==========================================
-- NOTE: We are deliberately setting 'phone' as an INT for Task 5
CREATE TABLE owner (
    owner_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone INT 
);

CREATE TABLE pet (
    pet_id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    species VARCHAR(50),
    breed VARCHAR(50),
    date_of_birth DATE,
    FOREIGN KEY (owner_id) REFERENCES owner(owner_id)
);

CREATE TABLE veterinarian (
    vet_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100)
);

-- ==========================================
-- Task 3: Create the Relationship Tables
-- ==========================================
CREATE TABLE appointment (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    pet_id INT NOT NULL,
    vet_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    reason VARCHAR(255),
    FOREIGN KEY (pet_id) REFERENCES pet(pet_id),
    FOREIGN KEY (vet_id) REFERENCES veterinarian(vet_id)
);

CREATE TABLE vaccination_record (
    vaccination_id INT AUTO_INCREMENT PRIMARY KEY,
    pet_id INT NOT NULL,
    vaccine_name VARCHAR(100) NOT NULL,
    date_administered DATE NOT NULL,
    FOREIGN KEY (pet_id) REFERENCES pet(pet_id)
);

-- ==========================================
-- Task 4: Verify the Schema
-- ==========================================
SHOW TABLES;
DESCRIBE owner;
DESCRIBE pet;
DESCRIBE veterinarian;
DESCRIBE appointment;
DESCRIBE vaccination_record;

-- ==========================================
-- Task 5: Fix a Deliberate Mistake
-- ==========================================
-- The 'phone' column in 'owner' was created as an INT, which is bad for phone numbers.
-- We fix it by altering the table to change the data type to VARCHAR.
ALTER TABLE owner MODIFY COLUMN phone VARCHAR(20);

-- Verify the fix
DESCRIBE owner;