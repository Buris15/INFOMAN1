# INFOMAN1 — Week 13 F1 Checkpoint

## Shared project and database

- Project: Pet Veterinary Clinic
- Shared schema name: `infoman1_vetclinic_finals`
- Server requirement: MySQL 8.0.16+ with InnoDB.
- Actual MySQL server version: PENDING — run `SELECT VERSION();` and record it.
- Shared WEBDEV2 repository/branch: PENDING — record the exact `week13` branch URL after creating it from the latest working final-project branch.
- Shared WEBDEV2 application path: repository root; do not copy the app into this INFOMAN1 folder.

## Execution order

1. `schema.sql` — create the fresh shared Finals schema and five related InnoDB tables.
2. `seed.sql` — insert fictional linked data and show row counts.
3. `views.sql` — create two join-based views and query the appointment report.
4. `evidence/schema_inspection.sql` — capture server version, tables, DDL, and row counts.
5. `evidence/constraint_rejection_tests.sql` — execute duplicate microchip, invalid FK, and negative-age attempts in disposable test conditions.
6. `evidence/view_live_change_test.sql` — demonstrate that view output reflects a base-table update, then roll the test back.
7. Run the WEBDEV2 application on the same schema and capture the UI/API/SQL comparison.

Run each SQL file in MySQL Workbench or the MySQL client. Example client commands:

```bash
mysql -u <MYSQL_USERNAME> -p < schema.sql
mysql -u <MYSQL_USERNAME> -p < seed.sql
mysql -u <MYSQL_USERNAME> -p < views.sql
mysql -u <MYSQL_USERNAME> -p < evidence/schema_inspection.sql
mysql -u <MYSQL_USERNAME> -p < evidence/constraint_rejection_tests.sql
mysql -u <MYSQL_USERNAME> -p < evidence/view_live_change_test.sql
```

These scripts use `infoman1_vetclinic_finals`. They do not drop old databases or existing tables. If tables already exist, do not rerun blindly; inspect the schema or use a clean disposable database.

## Six requirements → implementation → evidence

| Requirement | Implementation | Evidence |
|---|---|---|
| Owner details stored once | `owner` table | `SHOW CREATE TABLE owner`; owner SELECT |
| Each pet has one owner and unique chip | `pet.owner_id` FK, unique microchip, age CHECK | Pet SELECT; duplicate microchip and invalid FK tests |
| Veterinarian directory | `veterinarian` table | Veterinarian SELECT and DDL |
| Appointment links pet and vet | Appointment FKs | `vw_appointment_overview` output; invalid-FK tests |
| Pet vaccination history | Weak entity/composite PK | `SHOW CREATE TABLE vaccination_record`; view output |
| Reusable joined report and app read | Views + shared WEBDEV2 API | View before/after test; browser row, Network response, matching SQL SELECT |

## Known issues / unfinished evidence

- Previous clinic DDL and WEBDEV2 Pet CRUD code were created against different database shapes. F1 now defines one shared schema and matching JPA entity mappings.
- The Week 8 WEBDEV2 `application.properties` used a MariaDB JDBC URL and a separate `webdev2_week8` database. The final handbook requires a MySQL server; confirm the actual server is MySQL 8.0.16+.
- Actual MySQL version, SQL execution output, Maven run, and application/browser evidence are PENDING until run locally.
- Do not write “passed” in the checkpoint until the corresponding real test output exists.

## Change log

- Consolidated the prior veterinary-clinic ERD/DDL and WEBDEV2 Pet model into one shared schema.
- Added required globally unique microchip number and breed to the pet table.
- Added deterministic seed data, appointment/vaccination join views, inspection scripts, and constraint tests.
- Linked the INFOMAN1 F1 evidence plan to the shared WEBDEV2 application instead of duplicating that code here.

Actual MySQL server version: 8.0.46
Database server: MySQL Community Server
Port: 3307
Database: infoman1_vetclinic_finals
