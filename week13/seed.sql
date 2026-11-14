-- Deterministic fictional seed records. Run after schema.sql against an empty project database.
USE infoman1_vetclinic_finals;

INSERT INTO owner (owner_id, first_name, last_name, phone_number) VALUES
(1001, 'Ana', 'Cruz', '09171230001'),
(1002, 'Ben', 'Santos', '09171230002'),
(1003, 'Cara', 'Reyes', '09171230003');

INSERT INTO veterinarian (vet_id, first_name, last_name, specialization) VALUES
(3001, 'Mira', 'Dela Cruz', 'General Veterinary Care'),
(3002, 'James', 'Lim', 'Veterinary Surgery'),
(3003, 'Sofia', 'Navarro', 'Dermatology');

INSERT INTO pet (pet_id, microchip_number, name, species, breed, age, owner_id) VALUES
(2001, 'MC-0001', 'Max', 'Dog', 'Golden Retriever', 5, 1001),
(2002, 'MC-0002', 'Luna', 'Cat', 'Persian', 3, 1001),
(2003, 'MC-0003', 'Mochi', 'Rabbit', 'Holland Lop', 2, 1002),
(2004, 'MC-0004', 'Rocky', 'Dog', 'Beagle', 7, 1003);

INSERT INTO appointment (appointment_id, appointment_date, reason_for_visit, pet_id, vet_id) VALUES
(4001, '2026-11-10', 'Routine wellness check', 2001, 3001),
(4002, '2026-11-12', 'Skin irritation consultation', 2002, 3003),
(4003, '2026-11-20', 'Post-treatment follow-up', 2003, 3001),
(4004, '2026-11-24', 'Pre-surgery assessment', 2004, 3002);

INSERT INTO vaccination_record (pet_id, vaccine_name, vaccination_date) VALUES
(2001, 'Anti-rabies', '2026-01-10'),
(2001, 'DHPP', '2026-02-10'),
(2002, 'Feline core vaccine', '2026-03-05'),
(2004, 'Anti-rabies', '2025-12-01');

SELECT 'owner' AS table_name, COUNT(*) AS row_count FROM owner
UNION ALL SELECT 'veterinarian', COUNT(*) FROM veterinarian
UNION ALL SELECT 'pet', COUNT(*) FROM pet
UNION ALL SELECT 'appointment', COUNT(*) FROM appointment
UNION ALL SELECT 'vaccination_record', COUNT(*) FROM vaccination_record;
