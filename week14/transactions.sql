-- INFOMAN1 Week 14 — COMMIT, controlled ROLLBACK, and SAVEPOINT demonstrations.
-- Domain: Pet Veterinary Clinic.
-- Database: infoman1_vetclinic_finals.
-- Prerequisites:
--   1) Week 13 schema.sql and seed.sql have already been executed.
--   2) Week 14 alter_week14.sql has already been executed.
--   3) Run only against the disposable academic project database.
--
-- This script is designed to be safe to source more than once:
--   A) If the labelled committed test appointment already exists, it is skipped.
--   B) The forced-failure transaction rolls back its first write.
--   C) The savepoint demo fully rolls back its temporary records/slot change.

USE infoman1_vetclinic_finals;

-- Show the baseline schedule values before any demonstration.
SELECT vet_id, availability_date, total_slots, available_slots
FROM vet_availability
WHERE (vet_id = 3001 AND availability_date = '2026-11-20')
   OR (vet_id = 3003 AND availability_date = '2026-11-21')
   OR (vet_id = 3001 AND availability_date = '2026-11-22')
ORDER BY availability_date, vet_id;

-- -----------------------------------------------------------------------------
-- A. SUCCESSFUL ATOMIC BOOKING: decrease one slot + insert one appointment.
-- Both writes are inside one transaction. The test is skipped on repeat runs.
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS w14_successful_booking;
DELIMITER $$
CREATE PROCEDURE w14_successful_booking()
BEGIN
    DECLARE changed_rows INT DEFAULT 0;
    DECLARE existing_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET @w14_success_result = 'FAIL: an SQL error occurred; transaction rolled back.';
        SET @w14_success_appointment_id = NULL;
    END;

    SET @w14_success_appointment_id = NULL;
    SELECT COUNT(*) INTO existing_count
    FROM appointment
    WHERE appointment_date = '2026-11-20'
      AND reason_for_visit = 'INFOMAN1 W14 committed atomic booking test';

    IF existing_count > 0 THEN
        SET @w14_success_result = 'SKIPPED: the labelled committed test appointment already exists.';
    ELSE
        START TRANSACTION;

        UPDATE vet_availability
           SET available_slots = available_slots - 1
         WHERE vet_id = 3001
           AND availability_date = '2026-11-20'
           AND available_slots > 0;
        SET changed_rows = ROW_COUNT();

        IF changed_rows <> 1 THEN
            ROLLBACK;
            SET @w14_success_result = 'NOT RUN: veterinarian 3001 has no remaining slot on 2026-11-20.';
        ELSE
            INSERT INTO appointment (appointment_date, reason_for_visit, pet_id, vet_id)
            VALUES ('2026-11-20', 'INFOMAN1 W14 committed atomic booking test', 2001, 3001);
            SET @w14_success_appointment_id = LAST_INSERT_ID();
            COMMIT;
            SET @w14_success_result = 'PASS: one veterinarian slot and one appointment were committed together.';
        END IF;
    END IF;

    SELECT @w14_success_result AS result,
           @w14_success_appointment_id AS committed_appointment_id;
END$$
DELIMITER ;

SELECT vet_id, availability_date, available_slots AS before_commit_test
FROM vet_availability
WHERE vet_id = 3001 AND availability_date = '2026-11-20';
CALL w14_successful_booking();
DROP PROCEDURE w14_successful_booking;

-- These queries prove that the two related records changed after COMMIT.
SELECT appointment_id, appointment_date, reason_for_visit, pet_id, vet_id
FROM appointment
WHERE appointment_date = '2026-11-20'
  AND reason_for_visit = 'INFOMAN1 W14 committed atomic booking test'
ORDER BY appointment_id;
SELECT vet_id, availability_date, total_slots, available_slots AS after_commit_test
FROM vet_availability
WHERE vet_id = 3001 AND availability_date = '2026-11-20';

-- -----------------------------------------------------------------------------
-- B. CONTROLLED FAILURE AFTER FIRST WRITE.
-- The availability decrement succeeds first. The appointment INSERT then fails
-- because pet_id 99999999 does not exist. The EXIT HANDLER rolls back the slot.
-- The handler records the SQL error but handles it, allowing SOURCE to continue.
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS w14_forced_rollback;
DELIMITER $$
CREATE PROCEDURE w14_forced_rollback()
BEGIN
    DECLARE changed_rows INT DEFAULT 0;
    DECLARE first_write_done BOOLEAN DEFAULT FALSE;
    DECLARE caught_errno INT DEFAULT NULL;
    DECLARE caught_message VARCHAR(512) DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            caught_errno = MYSQL_ERRNO,
            caught_message = MESSAGE_TEXT;
        ROLLBACK;
        SET @w14_rollback_errno = caught_errno;
        SET @w14_rollback_message = caught_message;
        SET @w14_rollback_first_write_done = first_write_done;
    END;

    SET @w14_rollback_errno = NULL;
    SET @w14_rollback_message = NULL;
    SET @w14_rollback_first_write_done = FALSE;

    START TRANSACTION;
    UPDATE vet_availability
       SET available_slots = available_slots - 1
     WHERE vet_id = 3003
       AND availability_date = '2026-11-21'
       AND available_slots > 0;
    SET changed_rows = ROW_COUNT();

    IF changed_rows <> 1 THEN
        ROLLBACK;
        SET @w14_rollback_message = 'No schedule slot was changed; check the seeded date/capacity.';
        SET @w14_rollback_first_write_done = FALSE;
    ELSE
        SET first_write_done = TRUE;

        -- Intentional foreign-key failure after the availability row was changed.
        INSERT INTO appointment (appointment_date, reason_for_visit, pet_id, vet_id)
        VALUES ('2026-11-21', 'INFOMAN1 W14 forced failure test', 99999999, 3003);

        -- Reaching this point would mean the invalid foreign key unexpectedly passed.
        COMMIT;
        SET @w14_rollback_message = 'Unexpected: invalid pet INSERT succeeded.';
        SET @w14_rollback_first_write_done = FALSE;
    END IF;
END$$
DELIMITER ;

SELECT vet_id, availability_date, available_slots AS before_forced_failure
FROM vet_availability
WHERE vet_id = 3003 AND availability_date = '2026-11-21';
CALL w14_forced_rollback();
DROP PROCEDURE w14_forced_rollback;

SELECT CASE
         WHEN @w14_rollback_first_write_done = TRUE AND @w14_rollback_errno = 1452
           THEN 'PASS: foreign-key insert failed after first write; ROLLBACK restored the slot.'
         WHEN @w14_rollback_first_write_done = FALSE
           THEN 'NOT PROVEN: the first schedule write did not complete; inspect capacity/date.'
         ELSE 'FAIL: expected foreign-key failure was not captured.'
       END AS rollback_result,
       @w14_rollback_errno AS captured_mysql_error,
       @w14_rollback_message AS captured_error_message;

-- The after-state must match before_forced_failure; no invalid appointment may exist.
SELECT vet_id, availability_date, available_slots AS after_rollback
FROM vet_availability
WHERE vet_id = 3003 AND availability_date = '2026-11-21';
SELECT COUNT(*) AS failed_appointment_rows
FROM appointment
WHERE appointment_date = '2026-11-21'
  AND reason_for_visit = 'INFOMAN1 W14 forced failure test';

-- -----------------------------------------------------------------------------
-- C. SAVEPOINT: ROLLBACK TO SAVEPOINT undoes only the later UPDATE.
-- The appointment INSERT and slot decrement remain temporarily in the same
-- transaction. The final full ROLLBACK then removes/restores both earlier writes.
-- -----------------------------------------------------------------------------
SELECT vet_id, availability_date, available_slots AS before_savepoint_test
FROM vet_availability
WHERE vet_id = 3001 AND availability_date = '2026-11-22';

START TRANSACTION;
UPDATE vet_availability
   SET available_slots = available_slots - 1
 WHERE vet_id = 3001
   AND availability_date = '2026-11-22'
   AND available_slots > 0;
SET @w14_savepoint_slots_changed = ROW_COUNT();
SELECT @w14_savepoint_slots_changed AS slots_reserved_should_be_1;

INSERT INTO appointment (appointment_date, reason_for_visit, pet_id, vet_id)
VALUES ('2026-11-22', 'INFOMAN1 W14 savepoint test - original reason', 2002, 3001);
SET @w14_savepoint_appointment_id = LAST_INSERT_ID();

SAVEPOINT after_appointment_insert;
UPDATE appointment
   SET reason_for_visit = 'INFOMAN1 W14 savepoint test - temporary update'
 WHERE appointment_id = @w14_savepoint_appointment_id;

ROLLBACK TO SAVEPOINT after_appointment_insert;

-- Partial rollback: appointment and reserved slot still exist; later UPDATE is undone.
SELECT appointment_id, reason_for_visit
FROM appointment
WHERE appointment_id = @w14_savepoint_appointment_id;
SELECT vet_id, availability_date, available_slots AS during_transaction_after_partial_rollback
FROM vet_availability
WHERE vet_id = 3001 AND availability_date = '2026-11-22';

-- Full rollback: the appointment is removed and the reserved slot is restored.
ROLLBACK;
SELECT COUNT(*) AS appointment_rows_after_full_rollback
FROM appointment
WHERE appointment_id = @w14_savepoint_appointment_id;
SELECT vet_id, availability_date, available_slots AS after_full_rollback
FROM vet_availability
WHERE vet_id = 3001 AND availability_date = '2026-11-22';

-- -----------------------------------------------------------------------------
-- D. OPTIONAL CLEANUP of the committed success test.
-- Run only after capturing COMMIT evidence, and only in this academic database.
-- This section intentionally remains commented out so the commit is observable.
-- Use the current session: @w14_success_appointment_id was set by section A.
-- If section A was SKIPPED because the test already existed, look up its ID first.
-- -----------------------------------------------------------------------------
-- START TRANSACTION;
-- UPDATE vet_availability
--    SET available_slots = available_slots + 1
--  WHERE vet_id = 3001 AND availability_date = '2026-11-20'
--    AND available_slots < total_slots
--    AND EXISTS (
--        SELECT 1 FROM appointment
--        WHERE appointment_id = @w14_success_appointment_id
--          AND vet_id = 3001 AND appointment_date = '2026-11-20'
--    );
-- DELETE FROM appointment WHERE appointment_id = @w14_success_appointment_id;
-- COMMIT;
