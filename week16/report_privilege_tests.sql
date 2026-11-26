-- Run as capstone_test_report using a fresh connection.
USE infoman1_vetclinic_test;
SELECT USER() AS connecting_user, CURRENT_USER() AS matched_account, DATABASE() AS selected_database;
SHOW GRANTS;
-- Allowed read: only the approved report view.
SELECT * FROM vw_week15_appointment_report ORDER BY appointment_date, appointment_id;
-- Expected to fail with ERROR 1142. WHERE 1=0 ensures no rows would change if misconfigured.
UPDATE appointment SET reason_for_visit=reason_for_visit WHERE 1=0;
