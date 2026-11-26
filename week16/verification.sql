-- INFOMAN1 Week 16 verification queries.
-- Run after mysql_test_setup.sql, preferably as the restricted test account for read checks.
-- This file is read-only. It does not modify fixture rows.
USE infoman1_vetclinic_test;

-- 1. Confirm version, target schema, and identity.
SELECT VERSION() AS mysql_version, @@port AS mysql_port,
       DATABASE() AS selected_database, USER() AS connecting_user,
       CURRENT_USER() AS matched_mysql_account;

-- 2. Baseline fixture counts. Expected: owner=1, veterinarians=2, pets=2,
-- appointments=1, vaccinations=1, availability rows=2.
SELECT 'owner' AS table_name, COUNT(*) AS row_count FROM owner
UNION ALL SELECT 'veterinarian', COUNT(*) FROM veterinarian
UNION ALL SELECT 'pet', COUNT(*) FROM pet
UNION ALL SELECT 'appointment', COUNT(*) FROM appointment
UNION ALL SELECT 'vaccination_record', COUNT(*) FROM vaccination_record
UNION ALL SELECT 'vet_availability', COUNT(*) FROM vet_availability;

-- 3. Report view values. Expected one seeded report row for the fixture appointment.
SELECT appointment_id, appointment_date, reason_for_visit,
       pet_name, species, veterinarian_name, specialization
FROM vw_week15_appointment_report
ORDER BY appointment_id;

-- 4. LEFT JOIN test: veterinarian 93002 has zero appointments and must remain in output.
-- Expected: vet 93001 has 1 appointment; vet 93002 has 0.
SELECT v.vet_id, CONCAT(v.first_name, ' ', v.last_name) AS veterinarian,
       COUNT(a.appointment_id) AS appointment_count
FROM veterinarian v
LEFT JOIN appointment a
  ON a.vet_id = v.vet_id
 AND a.appointment_date >= '2098-12-01'
GROUP BY v.vet_id, v.first_name, v.last_name
ORDER BY v.vet_id;

-- 5. Vaccination report test: COUNT(vr.pet_id) gives 0 for a pet without vaccinations.
-- Expected: pet 92001 = 1; pet 92002 = 0.
SELECT p.pet_id, p.name,
       COUNT(vr.pet_id) AS vaccination_count
FROM pet p
LEFT JOIN vaccination_record vr ON vr.pet_id = p.pet_id
GROUP BY p.pet_id, p.name
ORDER BY p.pet_id;

-- 6. Referential-integrity checks.
SELECT COUNT(*) AS appointments_without_pet
FROM appointment a LEFT JOIN pet p ON p.pet_id = a.pet_id
WHERE p.pet_id IS NULL;
SELECT COUNT(*) AS appointments_without_veterinarian
FROM appointment a LEFT JOIN veterinarian v ON v.vet_id = a.vet_id
WHERE v.vet_id IS NULL;
SELECT COUNT(*) AS invalid_capacity_rows
FROM vet_availability
WHERE available_slots < 0 OR available_slots > total_slots;

-- 7. EXPLAIN an appointment filter/join used by the clinic report.
-- Inspect key / possible_keys / rows. With this tiny fixture a table scan may be reasonable.
EXPLAIN
SELECT a.appointment_id, a.appointment_date, p.name AS pet_name,
       CONCAT(v.first_name, ' ', v.last_name) AS veterinarian_name
FROM appointment a
JOIN pet p ON p.pet_id = a.pet_id
JOIN veterinarian v ON v.vet_id = a.vet_id
WHERE a.vet_id = 93001
  AND a.appointment_date >= '2098-12-01'
ORDER BY a.appointment_date, a.appointment_id;

-- Candidate index for the combined vet/date predicate (diagnostic recommendation only):
-- CREATE INDEX idx_appointment_vet_date ON appointment(vet_id, appointment_date);
-- Compare EXPLAIN before/after on a representative larger test dataset before adopting it.
