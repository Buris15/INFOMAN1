-- Run the ADMIN section as the MySQL administrator.
-- Then open a NEW capstone_report session for the denial test.
-- Finally return to the administrator session and run the restore section.
USE infoman1_vetclinic_finals;

-- ADMIN SECTION: effective report-view permission before revoke.
SHOW GRANTS FOR 'capstone_report'@'127.0.0.1';
REVOKE SELECT ON infoman1_vetclinic_finals.vw_week15_appointment_report
FROM 'capstone_report'@'127.0.0.1';
SHOW GRANTS FOR 'capstone_report'@'127.0.0.1';

-- REPORT SESSION SECTION (run in a fresh connection as capstone_report):
-- SELECT * FROM infoman1_vetclinic_finals.vw_week15_appointment_report;
-- Expected: ERROR 1142, SELECT command denied for this view.

-- ADMIN RESTORE SECTION: run only after capturing the denied SELECT result.
GRANT SELECT ON infoman1_vetclinic_finals.vw_week15_appointment_report
TO 'capstone_report'@'127.0.0.1';
SHOW GRANTS FOR 'capstone_report'@'127.0.0.1';

-- REPORT SESSION RESTORE CHECK (new report connection):
-- SELECT * FROM infoman1_vetclinic_finals.vw_week15_appointment_report LIMIT 5;
-- Expected: rows are readable again.
