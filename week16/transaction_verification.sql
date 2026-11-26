-- INFOMAN1 Week 16 transaction verification using disposable fixtures only.
-- Run in infoman1_vetclinic_test as the authorized local test-schema maintainer; this file creates a temporary test procedure.
USE infoman1_vetclinic_test;

-- Case TX-01: successful atomic commit. Re-runnable: remove only this named test record,
-- restore this dedicated test slot, then create both related changes in one transaction.
DELETE FROM appointment WHERE reason_for_visit='W16 SQL commit verification';
UPDATE vet_availability SET total_slots=1, available_slots=1
WHERE vet_id=93001 AND availability_date='2099-01-10';
SELECT available_slots AS before_available_slots FROM vet_availability
WHERE vet_id=93001 AND availability_date='2099-01-10';
START TRANSACTION;
UPDATE vet_availability
SET available_slots=available_slots-1
WHERE vet_id=93001 AND availability_date='2099-01-10' AND available_slots > 0;
SELECT ROW_COUNT() AS slot_rows_changed;
INSERT INTO appointment (appointment_date, reason_for_visit, pet_id, vet_id)
VALUES ('2099-01-10', 'W16 SQL commit verification', 92001, 93001);
COMMIT;
SELECT available_slots AS after_available_slots FROM vet_availability
WHERE vet_id=93001 AND availability_date='2099-01-10';
SELECT COUNT(*) AS committed_appointment_count FROM appointment
WHERE reason_for_visit='W16 SQL commit verification';

-- Case TX-02: controlled post-write failure handled inside a procedure so ROLLBACK executes.
-- The invalid pet FK is deliberate; the EXIT handler rolls back the prior slot decrement.
DROP PROCEDURE IF EXISTS w16_force_rollback_test;
DELIMITER //
CREATE PROCEDURE w16_force_rollback_test()
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT 'PASS: forced FK failure occurred after the slot write; transaction rolled back.' AS rollback_result;
  END;
  START TRANSACTION;
  UPDATE vet_availability
    SET available_slots=available_slots-1
    WHERE vet_id=93001 AND availability_date='2099-01-11' AND available_slots > 0;
  INSERT INTO appointment (appointment_date, reason_for_visit, pet_id, vet_id)
  VALUES ('2099-01-11', 'W16 SQL forced rollback verification', 99999999, 93001);
  COMMIT;
END//
DELIMITER ;

UPDATE vet_availability SET total_slots=1, available_slots=1
WHERE vet_id=93001 AND availability_date='2099-01-11';
SELECT available_slots AS before_available_slots FROM vet_availability
WHERE vet_id=93001 AND availability_date='2099-01-11';
CALL w16_force_rollback_test();
SELECT available_slots AS after_available_slots FROM vet_availability
WHERE vet_id=93001 AND availability_date='2099-01-11';
SELECT COUNT(*) AS failed_appointment_count FROM appointment
WHERE reason_for_visit='W16 SQL forced rollback verification';
DROP PROCEDURE IF EXISTS w16_force_rollback_test;

-- The committed example remains as evidence in the disposable test schema.
-- To return the test DB to its initial fixture state after evidence capture:
-- DELETE FROM appointment WHERE reason_for_visit='W16 SQL commit verification';
-- UPDATE vet_availability SET available_slots=1 WHERE vet_id=93001 AND availability_date='2099-01-10';
