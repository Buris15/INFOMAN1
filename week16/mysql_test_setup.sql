-- INFOMAN1 Week 16 — dedicated, disposable MySQL integration-test database.
-- Run only on your authorized LOCAL development MySQL instance as an administrator.
-- SAFETY: This script creates infoman1_vetclinic_test. It never drops databases or tables.
-- If this database already contains work you need, inspect it before running this script.

CREATE DATABASE IF NOT EXISTS infoman1_vetclinic_test
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE infoman1_vetclinic_test;

CREATE TABLE IF NOT EXISTS owner (
    owner_id BIGINT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    CONSTRAINT pk_owner PRIMARY KEY (owner_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS veterinarian (
    vet_id BIGINT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    CONSTRAINT pk_veterinarian PRIMARY KEY (vet_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pet (
    pet_id BIGINT NOT NULL AUTO_INCREMENT,
    microchip_number VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    species VARCHAR(50) NOT NULL,
    breed VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    owner_id BIGINT NOT NULL,
    CONSTRAINT pk_pet PRIMARY KEY (pet_id),
    CONSTRAINT uk_pet_microchip_number UNIQUE (microchip_number),
    CONSTRAINT chk_pet_age_nonnegative CHECK (age >= 0),
    CONSTRAINT fk_pet_owner FOREIGN KEY (owner_id)
      REFERENCES owner(owner_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_pet_owner_id (owner_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS appointment (
    appointment_id BIGINT NOT NULL AUTO_INCREMENT,
    appointment_date DATE NOT NULL,
    reason_for_visit VARCHAR(255) NOT NULL,
    pet_id BIGINT NOT NULL,
    vet_id BIGINT NOT NULL,
    CONSTRAINT pk_appointment PRIMARY KEY (appointment_id),
    CONSTRAINT fk_appointment_pet FOREIGN KEY (pet_id)
      REFERENCES pet(pet_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appointment_veterinarian FOREIGN KEY (vet_id)
      REFERENCES veterinarian(vet_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_appointment_pet_id (pet_id),
    INDEX idx_appointment_vet_id (vet_id),
    INDEX idx_appointment_date (appointment_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS vaccination_record (
    pet_id BIGINT NOT NULL,
    vaccine_name VARCHAR(100) NOT NULL,
    vaccination_date DATE NOT NULL,
    CONSTRAINT pk_vaccination_record PRIMARY KEY (pet_id, vaccine_name, vaccination_date),
    CONSTRAINT fk_vaccination_pet FOREIGN KEY (pet_id)
      REFERENCES pet(pet_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_vaccination_date (vaccination_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS vet_availability (
    vet_id BIGINT NOT NULL,
    availability_date DATE NOT NULL,
    total_slots INT NOT NULL,
    available_slots INT NOT NULL,
    CONSTRAINT pk_vet_availability PRIMARY KEY (vet_id, availability_date),
    CONSTRAINT fk_vet_availability_veterinarian FOREIGN KEY (vet_id)
      REFERENCES veterinarian(vet_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_vet_availability_total CHECK (total_slots >= 0),
    CONSTRAINT chk_vet_availability_remaining CHECK (
      available_slots >= 0 AND available_slots <= total_slots
    )
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS app_user (
    user_id BIGINT NOT NULL AUTO_INCREMENT,
    username VARCHAR(60) NOT NULL,
    password_hash VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL,
    enabled TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_app_user PRIMARY KEY (user_id),
    CONSTRAINT uk_app_user_username UNIQUE (username),
    CONSTRAINT chk_app_user_role CHECK (role IN ('MANAGER', 'READER'))
) ENGINE=InnoDB;

-- Reset only this package's named transaction-test records in the disposable schema.
-- The availability rows below are also reset to their known starting capacity.
DELETE FROM appointment
WHERE reason_for_visit IN (
  'W16 SQL commit verification',
  'W16 SQL forced rollback verification',
  'W16 Spring service commit integration',
  'W16 Spring service rollback integration'
);

-- Deterministic fictional fixtures; reruns refresh these known test rows only.
INSERT INTO owner (owner_id, first_name, last_name, phone_number)
VALUES (91001, 'Test', 'Owner', '09000000001')
ON DUPLICATE KEY UPDATE first_name=VALUES(first_name), last_name=VALUES(last_name), phone_number=VALUES(phone_number);

INSERT INTO veterinarian (vet_id, first_name, last_name, specialization)
VALUES
 (93001, 'Ivy', 'Tester', 'General Veterinary Care'),
 (93002, 'Noah', 'Zero', 'Diagnostics')
ON DUPLICATE KEY UPDATE first_name=VALUES(first_name), last_name=VALUES(last_name), specialization=VALUES(specialization);

INSERT INTO pet (pet_id, microchip_number, name, species, breed, age, owner_id)
VALUES
 (92001, 'W16-MC-92001', 'Integration Pet', 'Dog', 'Mixed Breed', 2, 91001),
 (92002, 'W16-MC-92002', 'Delete Fixture', 'Cat', 'Domestic Shorthair', 3, 91001)
ON DUPLICATE KEY UPDATE microchip_number=VALUES(microchip_number), name=VALUES(name), species=VALUES(species), breed=VALUES(breed), age=VALUES(age), owner_id=VALUES(owner_id);

INSERT INTO vaccination_record (pet_id, vaccine_name, vaccination_date)
VALUES (92001, 'Week16 Test Vaccine', '2098-12-01')
ON DUPLICATE KEY UPDATE vaccination_date=VALUES(vaccination_date);

-- One appointment gives the report a known non-zero row; veterinarian 93002 has none.
INSERT INTO appointment (appointment_id, appointment_date, reason_for_visit, pet_id, vet_id)
VALUES (94001, '2098-12-15', 'W16 seeded report fixture', 92001, 93001)
ON DUPLICATE KEY UPDATE appointment_date=VALUES(appointment_date), reason_for_visit=VALUES(reason_for_visit), pet_id=VALUES(pet_id), vet_id=VALUES(vet_id);

-- Test rows used by AppointmentTransactionMySqlTest. Both start with one free slot.
INSERT INTO vet_availability (vet_id, availability_date, total_slots, available_slots)
VALUES
 (93001, '2099-01-10', 1, 1),
 (93001, '2099-01-11', 1, 1)
ON DUPLICATE KEY UPDATE total_slots=VALUES(total_slots), available_slots=VALUES(available_slots);

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW vw_week15_appointment_report AS
SELECT a.appointment_id, a.appointment_date, a.reason_for_visit,
       p.name AS pet_name, p.species,
       CONCAT(v.first_name, ' ', v.last_name) AS veterinarian_name,
       v.specialization
FROM appointment a
JOIN pet p ON p.pet_id=a.pet_id
JOIN veterinarian v ON v.vet_id=a.vet_id;

SELECT 'owner' AS table_name, COUNT(*) AS row_count FROM owner
UNION ALL SELECT 'veterinarian', COUNT(*) FROM veterinarian
UNION ALL SELECT 'pet', COUNT(*) FROM pet
UNION ALL SELECT 'appointment', COUNT(*) FROM appointment
UNION ALL SELECT 'vaccination_record', COUNT(*) FROM vaccination_record
UNION ALL SELECT 'vet_availability', COUNT(*) FROM vet_availability;
