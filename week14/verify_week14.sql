-- INFOMAN1 Week 14 verification queries. Run after alter_week14.sql.
USE infoman1_vetclinic_finals;

SELECT VERSION() AS mysql_version, @@port AS mysql_port;
SHOW CREATE TABLE vet_availability;

-- Expected seeded coverage: 426 rows (3 veterinarians x 142 calendar days),
-- from 2026-11-10 through 2027-03-31.
SELECT COUNT(*) AS schedule_rows,
       MIN(availability_date) AS first_schedule_date,
       MAX(availability_date) AS last_schedule_date
FROM vet_availability;

SELECT v.vet_id,
       CONCAT(v.first_name, ' ', v.last_name) AS veterinarian,
       COUNT(*) AS scheduled_days,
       SUM(va.total_slots) AS total_capacity,
       SUM(va.available_slots) AS remaining_capacity
FROM veterinarian AS v
JOIN vet_availability AS va ON va.vet_id = v.vet_id
GROUP BY v.vet_id, v.first_name, v.last_name
ORDER BY v.vet_id;

-- Existing appointments must have a matching veterinarian/date availability row.
SELECT COUNT(*) AS appointments_without_schedule
FROM appointment AS a
LEFT JOIN vet_availability AS va
  ON va.vet_id = a.vet_id
 AND va.availability_date = a.appointment_date
WHERE va.vet_id IS NULL;

-- Useful multi-table report from the Week 13 view, plus capacity status.
SELECT a.appointment_id, a.appointment_date, p.name AS pet_name,
       CONCAT(v.first_name, ' ', v.last_name) AS veterinarian_name,
       va.available_slots, va.total_slots
FROM appointment AS a
JOIN pet AS p ON p.pet_id = a.pet_id
JOIN veterinarian AS v ON v.vet_id = a.vet_id
LEFT JOIN vet_availability AS va
       ON va.vet_id = a.vet_id AND va.availability_date = a.appointment_date
ORDER BY a.appointment_date, a.appointment_id;

-- Check the invariant: capacity is never negative or above total capacity.
SELECT COUNT(*) AS invalid_capacity_rows
FROM vet_availability
WHERE available_slots < 0 OR available_slots > total_slots;
