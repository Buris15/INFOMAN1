# INFOMAN1 Week 14 evidence

Save real screenshots from your own MySQL CMD or MySQL Workbench session here. Do not use mock screenshots or claim a query passed before you run it.

Recommended screenshots:

1. `01_mysql_version_tables.png` — `SELECT VERSION(), @@port;` and `SHOW TABLES;` showing your existing tables.
2. `02_availability_migration.png` — successful `alter_week14.sql`, `SHOW CREATE TABLE vet_availability`, and a sample schedule query.
3. `03_verification.png` — `verify_week14.sql` results, including `schedule_rows`, `appointments_without_schedule`, and `invalid_capacity_rows`.
4. `04_commit_success.png` — the COMMIT procedure result and the appointment row plus reduced availability afterwards.
5. `05_forced_rollback.png` — the captured foreign-key error/rollback result and unchanged availability/zero failed appointment rows.
6. `06_savepoint_partial.png` — result after `ROLLBACK TO SAVEPOINT`, showing the inserted appointment with its original reason still in the open transaction.
7. `07_savepoint_full.png` — after full `ROLLBACK`, appointment count is zero and available capacity is restored.

Use Windows + Shift + S, capture the SQL and result together, then save PNG files in this folder.
