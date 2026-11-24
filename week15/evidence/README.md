# INFOMAN1 Week 15 Evidence

Capture real output from your own MySQL server. Do not fabricate results and do not include passwords.

Suggested filenames:

1. `01_auth_user_table.png` — `DESCRIBE app_user` after `auth_schema.sql`.
2. `02_database_user_grants.png` — administrator output for both `SHOW GRANTS` statements (redact account details only if needed; keep usernames and privileges readable).
3. `03_definer_view.png` — `SHOW CREATE VIEW vw_week15_appointment_report` showing `SQL SECURITY DEFINER`.
4. `04_runtime_identity_allowed.png` — logged in as `capstone_app`; `USER()`, `CURRENT_USER()`, `SHOW GRANTS`, successful SELECT.
5. `05_runtime_ddl_denied.png` — runtime CREATE TABLE attempt rejected with error 1142.
6. `06_report_view_allowed.png` — `capstone_report` identity and successful view SELECT.
7. `07_report_base_write_denied.png` — UPDATE on `appointment` rejected with error 1142.
8. `08_report_select_revoked.png` — after REVOKE, new report session's view SELECT denied.
9. `09_report_select_restored.png` — after GRANT restore, new report session reads the view again.

Do not screenshot the password prompt while typing. Do not store real database passwords in the evidence folder.
