-- Run after connecting as capstone_report, not root or capstone_app.
-- Example client: mysql -h 127.0.0.1 -P 3307 -u capstone_report -p infoman1_vetclinic_finals
USE infoman1_vetclinic_finals;

SELECT USER() AS connecting_client,
       CURRENT_USER() AS matched_mysql_account,
       DATABASE() AS selected_database;
SHOW GRANTS;

-- ALLOWED: this view exposes only approved report columns.
SELECT *
FROM vw_week15_appointment_report
ORDER BY appointment_date, appointment_id
LIMIT 20;

-- DENIAL TEST: expected MySQL ERROR 1142 (UPDATE command denied).
-- WHERE 1=0 ensures no rows would be changed even if the account were misconfigured.
UPDATE appointment
SET reason_for_visit = reason_for_visit
WHERE 1 = 0;
