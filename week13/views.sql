-- Views are read definitions; they reflect current base-table rows.
USE infoman1_vetclinic_finals;

CREATE OR REPLACE VIEW vw_appointment_overview AS
SELECT
    a.appointment_id,
    a.appointment_date,
    a.reason_for_visit,
    p.pet_id,
    p.name AS pet_name,
    p.species,
    p.breed,
    p.microchip_number,
    CONCAT(o.first_name, ' ', o.last_name) AS owner_name,
    o.phone_number AS owner_phone,
    v.vet_id,
    CONCAT(v.first_name, ' ', v.last_name) AS veterinarian_name,
    v.specialization
FROM appointment AS a
JOIN pet AS p ON p.pet_id = a.pet_id
JOIN owner AS o ON o.owner_id = p.owner_id
JOIN veterinarian AS v ON v.vet_id = a.vet_id;

CREATE OR REPLACE VIEW vw_pet_vaccination_history AS
SELECT
    p.pet_id,
    p.name AS pet_name,
    p.species,
    CONCAT(o.first_name, ' ', o.last_name) AS owner_name,
    vr.vaccine_name,
    vr.vaccination_date
FROM pet AS p
JOIN owner AS o ON o.owner_id = p.owner_id
LEFT JOIN vaccination_record AS vr ON vr.pet_id = p.pet_id;

SELECT appointment_id, appointment_date, pet_name, owner_name,
       veterinarian_name, reason_for_visit
FROM vw_appointment_overview
ORDER BY appointment_date, appointment_id;
