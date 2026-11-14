# INFOMAN1 F1 evidence collection

Capture real MySQL results and screenshots here:

1. `01_mysql_version.png` — actual `SELECT VERSION()` output; must show MySQL Server 8.0.16+.
2. `02_show_tables_and_ddl.png` — five tables and their `SHOW CREATE TABLE` output with keys, constraints, and InnoDB.
3. `03_seed_counts.png` — row counts showing owner 3, veterinarian 3, pet 4, appointment 4, vaccination_record 4.
4. `04_appointment_view.png` — actual `vw_appointment_overview` output.
5. `05_view_before_after.png` — changed base value appears in view; transaction rolled back.
6. `06_constraint_rejections.png` — duplicate microchip, invalid owner FK, and negative age rejected.
7. `07_application_sql_match.png` — one browser/API pet record matched with direct SQL output.

The `.sql` files in this folder are test scripts, not screenshots or proof that MySQL has already been run.
