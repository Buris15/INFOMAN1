-- Run in a disposable test copy or after confirming these sample keys are unused.
USE infoman1_vetclinic_finals;

DELIMITER //
CREATE PROCEDURE run_clinic_constraint_checks()
BEGIN
    DECLARE duplicate_rejected BOOLEAN DEFAULT FALSE;
    DECLARE fk_rejected BOOLEAN DEFAULT FALSE;
    DECLARE age_rejected BOOLEAN DEFAULT FALSE;

    START TRANSACTION;

    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET duplicate_rejected = TRUE;
        INSERT INTO pet (microchip_number, name, species, breed, age, owner_id)
        VALUES ('MC-0001', 'Duplicate Chip Test', 'Dog', 'Mixed', 1, 1001);
    END;

    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET fk_rejected = TRUE;
        INSERT INTO pet (microchip_number, name, species, breed, age, owner_id)
        VALUES ('MC-FK-TEST', 'Invalid Owner Test', 'Dog', 'Mixed', 1, 99999999);
    END;

    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET age_rejected = TRUE;
        INSERT INTO pet (microchip_number, name, species, breed, age, owner_id)
        VALUES ('MC-AGE-TEST', 'Negative Age Test', 'Dog', 'Mixed', -1, 1001);
    END;

    SELECT
        IF(duplicate_rejected, 'PASS: duplicate microchip rejected', 'FAIL: duplicate microchip was accepted') AS duplicate_microchip_test,
        IF(fk_rejected, 'PASS: invalid owner FK rejected', 'FAIL: invalid owner FK was accepted') AS invalid_fk_test,
        IF(age_rejected, 'PASS: negative age rejected', 'FAIL: negative age was accepted') AS age_check_test;

    ROLLBACK;
END//
DELIMITER ;

CALL run_clinic_constraint_checks();
DROP PROCEDURE run_clinic_constraint_checks;

-- Confirm no test rows were inserted.
SELECT pet_id, microchip_number, name FROM pet
WHERE microchip_number IN ('MC-FK-TEST', 'MC-AGE-TEST');
