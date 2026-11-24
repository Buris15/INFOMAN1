-- Run this file only after connecting as capstone_app, not root.
-- Example client: mysql -h 127.0.0.1 -P 3307 -u capstone_app -p infoman1_vetclinic_finals
USE infoman1_vetclinic_finals;

SELECT USER() AS connecting_client,
       CURRENT_USER() AS matched_mysql_account,
       DATABASE() AS selected_database;
SHOW GRANTS;

-- Allowed: runtime can read records needed by clinic operations.
SELECT pet_id, name, species FROM pet ORDER BY pet_id LIMIT 5;
SELECT appointment_id, appointment_date, reason_for_visit
FROM appointment ORDER BY appointment_date, appointment_id LIMIT 5;
SELECT vet_id, availability_date, available_slots, total_slots
FROM vet_availability ORDER BY availability_date, vet_id LIMIT 5;

-- DENIAL TEST: expected MySQL ERROR 1142 (CREATE command denied).
-- If this unexpectedly succeeds, do not keep the table; tell the administrator to remove it.
CREATE TABLE w15_runtime_ddl_should_be_denied (id INT PRIMARY KEY);
