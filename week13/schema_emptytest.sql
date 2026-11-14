-- INFOMAN1 Week 13 F1 â€” Pet Veterinary Clinic
-- MySQL Server 8.0.16+ required; InnoDB tables; fresh dedicated shared Finals schema.
-- Does not drop a database or existing tables. Existing older lab tables must be reviewed first.

CREATE DATABASE IF NOT EXISTS infoman1_vetclinic_emptytest
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE infoman1_vetclinic_emptytest;

CREATE TABLE owner (
    owner_id BIGINT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    CONSTRAINT pk_owner PRIMARY KEY (owner_id)
) ENGINE=InnoDB;

CREATE TABLE veterinarian (
    vet_id BIGINT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    CONSTRAINT pk_veterinarian PRIMARY KEY (vet_id)
) ENGINE=InnoDB;

CREATE TABLE pet (
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
        REFERENCES owner(owner_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_pet_owner_id (owner_id)
) ENGINE=InnoDB;

CREATE TABLE appointment (
    appointment_id BIGINT NOT NULL AUTO_INCREMENT,
    appointment_date DATE NOT NULL,
    reason_for_visit VARCHAR(255) NOT NULL,
    pet_id BIGINT NOT NULL,
    vet_id BIGINT NOT NULL,
    CONSTRAINT pk_appointment PRIMARY KEY (appointment_id),
    CONSTRAINT fk_appointment_pet FOREIGN KEY (pet_id)
        REFERENCES pet(pet_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appointment_veterinarian FOREIGN KEY (vet_id)
        REFERENCES veterinarian(vet_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_appointment_pet_id (pet_id),
    INDEX idx_appointment_vet_id (vet_id),
    INDEX idx_appointment_date (appointment_date)
) ENGINE=InnoDB;

-- Weak entity: its identifying key includes the parent pet's key.
CREATE TABLE vaccination_record (
    pet_id BIGINT NOT NULL,
    vaccine_name VARCHAR(100) NOT NULL,
    vaccination_date DATE NOT NULL,
    CONSTRAINT pk_vaccination_record PRIMARY KEY (pet_id, vaccine_name, vaccination_date),
    CONSTRAINT fk_vaccination_pet FOREIGN KEY (pet_id)
        REFERENCES pet(pet_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_vaccination_date (vaccination_date)
) ENGINE=InnoDB;

