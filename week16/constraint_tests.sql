-- INFOMAN1 Week 16 constraint test cases.
-- Execute each numbered block individually in infoman1_vetclinic_test.
-- The expected-error statements intentionally fail; capture the error and then continue.
-- Do not run these against infoman1_vetclinic_finals or any production database.
USE infoman1_vetclinic_test;

-- CT-01 valid create/update/delete within a transaction; final ROLLBACK restores fixture.
START TRANSACTION;
INSERT INTO pet (microchip_number, name, species, breed, age, owner_id)
VALUES ('W16-TEMP-CRUD-001', 'Temporary CRUD Pet', 'Dog', 'Test', 1, 91001);
SET @created_pet_id = LAST_INSERT_ID();
SELECT pet_id, microchip_number, name FROM pet WHERE pet_id = @created_pet_id;
UPDATE pet SET name='Temporary CRUD Pet Updated' WHERE pet_id=@created_pet_id;
SELECT pet_id, name FROM pet WHERE pet_id=@created_pet_id;
DELETE FROM pet WHERE pet_id=@created_pet_id;
SELECT COUNT(*) AS deleted_row_count FROM pet WHERE pet_id=@created_pet_id;
ROLLBACK;

-- CT-02 invalid range. Expected CHECK constraint violation (typically error 3819).
START TRANSACTION;
INSERT INTO pet (microchip_number, name, species, breed, age, owner_id)
VALUES ('W16-INVALID-AGE', 'Invalid Age Pet', 'Dog', 'Test', -1, 91001);
ROLLBACK;

-- CT-03 duplicate unique microchip. Expected duplicate-key error 1062.
START TRANSACTION;
INSERT INTO pet (microchip_number, name, species, breed, age, owner_id)
VALUES ('W16-MC-92001', 'Duplicate Chip Pet', 'Dog', 'Test', 1, 91001);
ROLLBACK;

-- CT-04 invalid owner foreign key. Expected foreign-key error 1452.
START TRANSACTION;
INSERT INTO pet (microchip_number, name, species, breed, age, owner_id)
VALUES ('W16-INVALID-OWNER', 'Invalid Owner Pet', 'Cat', 'Test', 1, 99999999);
ROLLBACK;

-- CT-05 valid delete fixture with no related appointment/vaccination history.
-- Use a transaction so the fixture returns after ROLLBACK.
START TRANSACTION;
DELETE FROM pet WHERE pet_id=92002;
SELECT COUNT(*) AS deleted_fixture_count FROM pet WHERE pet_id=92002;
ROLLBACK;
SELECT COUNT(*) AS restored_fixture_count FROM pet WHERE pet_id=92002;
