USE infoman1_vetclinic_finals;

-- Select a known seeded appointment and save its original reason.
SELECT appointment_id, reason_for_visit
FROM vw_appointment_overview
WHERE appointment_id = 4001;

START TRANSACTION;
UPDATE appointment
SET reason_for_visit = 'F1 LIVE VIEW TEST — temporary value'
WHERE appointment_id = 4001;

-- The view should show the temporary value without being recreated.
SELECT appointment_id, pet_name, reason_for_visit
FROM vw_appointment_overview
WHERE appointment_id = 4001;

ROLLBACK;

-- The original value should be restored after rollback.
SELECT appointment_id, reason_for_visit
FROM vw_appointment_overview
WHERE appointment_id = 4001;
