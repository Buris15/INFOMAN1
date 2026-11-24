-- INFOMAN1 Week 15 F3 — least-privilege MySQL provisioning template.
-- AUTHORIZED LOCAL DEVELOPMENT DATABASE ONLY.
-- Before running: replace both password markers below with different strong local passwords.
-- Do not commit this working copy if it contains real passwords. Keep it outside Git.
-- Run as the local MySQL administrator/schema maintainer, not as capstone_app/report.
USE infoman1_vetclinic_finals;

-- A report view with only approved non-sensitive appointment fields.
-- Created by the administrator, so this is a SQL SECURITY DEFINER view.
-- The report account receives no SELECT grants on the underlying tables.
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW vw_week15_appointment_report AS
SELECT
    a.appointment_id,
    a.appointment_date,
    a.reason_for_visit,
    p.name AS pet_name,
    p.species,
    CONCAT(v.first_name, ' ', v.last_name) AS veterinarian_name,
    v.specialization
FROM appointment AS a
JOIN pet AS p ON p.pet_id = a.pet_id
JOIN veterinarian AS v ON v.vet_id = a.vet_id;

-- Exact host scope matches the application's TCP connection to 127.0.0.1.
-- IF NOT EXISTS avoids dropping/replacing an existing account. It does not reset its password.
CREATE USER IF NOT EXISTS 'capstone_app'@'127.0.0.1'
    IDENTIFIED BY 'CapstoneAPP';
CREATE USER IF NOT EXISTS 'capstone_report'@'127.0.0.1'
    IDENTIFIED BY 'CapstoneReport';

-- Runtime account: only the data privileges required by the current application.
-- Reference tables are read-only. The application mutates pets and appointments.
GRANT SELECT ON infoman1_vetclinic_finals.owner
    TO 'capstone_app'@'127.0.0.1';
GRANT SELECT ON infoman1_vetclinic_finals.veterinarian
    TO 'capstone_app'@'127.0.0.1';
GRANT SELECT, INSERT, UPDATE, DELETE ON infoman1_vetclinic_finals.pet
    TO 'capstone_app'@'127.0.0.1';
GRANT SELECT, INSERT, UPDATE, DELETE ON infoman1_vetclinic_finals.appointment
    TO 'capstone_app'@'127.0.0.1';
GRANT SELECT ON infoman1_vetclinic_finals.vaccination_record
    TO 'capstone_app'@'127.0.0.1';
GRANT SELECT, UPDATE ON infoman1_vetclinic_finals.vet_availability
    TO 'capstone_app'@'127.0.0.1';
GRANT SELECT ON infoman1_vetclinic_finals.app_user
    TO 'capstone_app'@'127.0.0.1';

-- Reporting account: SELECT on the approved view only, no base-table access.
GRANT SELECT ON infoman1_vetclinic_finals.vw_week15_appointment_report
    TO 'capstone_report'@'127.0.0.1';

-- Administrator evidence: inspect the effective grants and the view security context.
SHOW GRANTS FOR 'capstone_app'@'127.0.0.1';
SHOW GRANTS FOR 'capstone_report'@'127.0.0.1';
SHOW CREATE VIEW vw_week15_appointment_report;
