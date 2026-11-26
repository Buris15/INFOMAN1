-- Run as capstone_test_app using a fresh connection.
USE infoman1_vetclinic_test;
SELECT USER() AS connecting_user, CURRENT_USER() AS matched_account, DATABASE() AS selected_database;
SHOW GRANTS;
SELECT pet_id, name, species FROM pet ORDER BY pet_id;
SELECT appointment_id, appointment_date, reason_for_visit FROM appointment ORDER BY appointment_date;
-- Expected to fail with ERROR 1142. If it succeeds, tell the administrator and remove this table only in the test schema.
CREATE TABLE w16_runtime_ddl_should_be_denied (id INT PRIMARY KEY);
