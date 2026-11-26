-- Week 16 restricted identities for the disposable TEST schema only.
-- Replace both password markers in a PRIVATE local copy; never commit that copy.
-- Execute as an authorized local MySQL administrator after mysql_test_setup.sql.
CREATE USER IF NOT EXISTS 'capstone_test_app'@'127.0.0.1'
  IDENTIFIED BY 'REPLACE_WITH_A_UNIQUE_LOCAL_TEST_RUNTIME_PASSWORD';

GRANT SELECT ON infoman1_vetclinic_test.owner TO 'capstone_test_app'@'127.0.0.1';
GRANT SELECT ON infoman1_vetclinic_test.veterinarian TO 'capstone_test_app'@'127.0.0.1';
GRANT SELECT, INSERT, UPDATE, DELETE ON infoman1_vetclinic_test.pet TO 'capstone_test_app'@'127.0.0.1';
GRANT SELECT, INSERT, UPDATE, DELETE ON infoman1_vetclinic_test.appointment TO 'capstone_test_app'@'127.0.0.1';
GRANT SELECT ON infoman1_vetclinic_test.vaccination_record TO 'capstone_test_app'@'127.0.0.1';
GRANT SELECT, UPDATE ON infoman1_vetclinic_test.vet_availability TO 'capstone_test_app'@'127.0.0.1';
GRANT SELECT ON infoman1_vetclinic_test.app_user TO 'capstone_test_app'@'127.0.0.1';

CREATE USER IF NOT EXISTS 'capstone_test_report'@'127.0.0.1'
  IDENTIFIED BY 'REPLACE_WITH_A_DIFFERENT_LOCAL_TEST_REPORT_PASSWORD';
GRANT SELECT ON infoman1_vetclinic_test.vw_week15_appointment_report
  TO 'capstone_test_report'@'127.0.0.1';

SHOW GRANTS FOR 'capstone_test_app'@'127.0.0.1';
SHOW GRANTS FOR 'capstone_test_report'@'127.0.0.1';
