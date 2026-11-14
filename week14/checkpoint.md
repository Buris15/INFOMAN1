# INFOMAN1 — Week 14 F2 Checkpoint

## Project and repository continuity

- Project: Pet Veterinary Clinic.
- Database: `infoman1_vetclinic_finals`.
- MySQL: MySQL Community Server 8.0.46 on port 3307 (as recorded in Week 13).
- Existing Week 13 files remain unchanged.
- Application: shared WEBDEV2 Spring Boot application at repository root on the `week14` branch; do not duplicate it in this INFOMAN1 folder.
- Shared WEBDEV2 repository/branch URL: **replace with the real GitHub URL after pushing `week14`**.

Add this folder to the existing INFOMAN1 repository; do not replace `week13/`:

```bash
git add week14/
git commit -m "Add INFOMAN1 Week 14 CRUD transaction evidence"
git push
```

## Execution order

1. Existing database: keep the Week 13 schema, seed records, and views.
2. `alter_week14.sql` — create `vet_availability` and seed the fictional schedule.
3. `verify_week14.sql` — inspect the new table, capacity totals, appointment join, and capacity invariant.
4. `transactions.sql` — run success commit, forced post-write failure/rollback, and savepoint scenarios.
5. Start and test the shared WEBDEV2 `week14` application against this same MySQL schema.

For a clean test database, run INFOMAN1 `week13/schema.sql`, then `week13/seed.sql`, then `week13/views.sql`, followed by the Week 14 scripts. Do not run the Week 13 table-creation script blindly over an existing database.

## Requirement → feature → test/evidence

| Requirement | Feature / file | Test and evidence to capture |
|---|---|---|
| Two resources have CRUD | WEBDEV2 `/api/pets` and `/api/appointments` endpoints | Pet and appointment create/read/update/delete requests; re-query MySQL after each operation |
| Related veterinarian/date capacity | `vet_availability` table, `alter_week14.sql` | `SHOW CREATE TABLE`; capacity query in `verify_week14.sql` |
| A booking affects two records atomically | `AppointmentService.bookAppointment`; `transactions.sql` success case | New appointment row and decremented availability after commit, queried from another connection |
| Failure after the first write leaves no partial change | `AppointmentService.bookAppointment`; forced rollback procedure | Invalid pet booking response plus unchanged availability and no appointment row |
| Savepoint partial rollback is distinguished from full rollback | `transactions.sql` savepoint section | After `ROLLBACK TO SAVEPOINT`, appointment and slot decrement remain; after full `ROLLBACK`, neither remains |
| Concurrency is controlled | `VetAvailabilityRepository.lockByVetAndDate` uses `PESSIMISTIC_WRITE` | Explain lock and, when practical, run two concurrent requests competing for the last slot |
| Capacity invariant remains valid | CHECK constraints and conditional service check | `invalid_capacity_rows` query returns 0 |

## Setup commands

Run using MySQL Workbench or the MySQL client:

```bash
mysql -u <MYSQL_USERNAME> -p < week13/schema.sql
mysql -u <MYSQL_USERNAME> -p < week13/seed.sql
mysql -u <MYSQL_USERNAME> -p < week13/views.sql
mysql -u <MYSQL_USERNAME> -p < week14/alter_week14.sql
mysql -u <MYSQL_USERNAME> -p < week14/verify_week14.sql
mysql -u <MYSQL_USERNAME> -p < week14/transactions.sql
```

If the Week 13 database already exists, run only `week14/alter_week14.sql` and the Week 14 verification/test scripts.

## Actual versus expected results

| Test | Expected | Actual result / evidence path |
|---|---|---|
| Schedule migration | 3 veterinarians have seeded availability rows for 2026-11-10 through 2027-03-31 | PENDING — record returned row count and screenshot |
| Successful booking commit | One appointment inserted and one slot decremented | PENDING — record appointment ID, SQL output, and second-connection query |
| Forced failure | Insert fails after slot decrement; transaction restores original slot count | PENDING — record procedure output and before/after SELECT |
| Savepoint rollback | Post-savepoint UPDATE is undone; pre-savepoint INSERT and slot decrement remain until full rollback | PENDING — capture both intermediate and final SELECT output |
| Application-level workflow | API booking endpoint commits both writes or rolls back both | PENDING — link WEBDEV2 request, response, and SQL verification |
| Capacity invariant | No row has a negative count or available count above total | PENDING — record `invalid_capacity_rows` result |

Do not mark a test as passed until it has been run against MySQL. Store screenshots/exports in `evidence/`.

## Known limitations / follow-up

- The supplied fictional availability seed currently covers 2026-11-10 through 2027-03-31. Add later schedule rows through an approved schedule-management workflow when needed; do not fabricate availability by editing browser state.
- The successful transaction example leaves one clearly labelled test appointment committed. The end of `transactions.sql` contains an optional compensating cleanup transaction; run it only after saving evidence and only in this academic database.
- A database server and browser are not available inside this preparation environment, so MySQL execution, API runtime behavior, and screenshots remain pending local verification.

## Change log

- Added the veterinarian/date capacity table with InnoDB, a composite primary key, FK, and CHECK constraints.
- Seeded fictional daily capacity for the three existing veterinarians.
- Added committed success, post-write failure/rollback, and savepoint scenarios.
- Added verification queries and documented the shared WEBDEV2 application transaction path.
