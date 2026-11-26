# INFOMAN1 Week 16 Lecture — Verified Database Integration

## 1. Three meaningful test choices

**Duplicate microchip (IF16-08).** The microchip number is a candidate key for a pet. The database UNIQUE constraint is authoritative because a second client can bypass the browser. The test attempts to insert `W16-MC-92001` again and checks that MySQL rejects the statement while the original `92001` pet remains unchanged.

**Invalid owner foreign key (IF16-09).** A pet must reference an existing owner. A request with `owner_id=99999999` must fail at the database FK even if a client-side selector is manipulated. The post-test count must show that no pet with the test microchip was persisted.

**Appointment capacity rollback (IF16-12).** The workflow first reduces `vet_availability.available_slots`, then attempts to insert an appointment for a nonexistent pet. The failure occurs after the first mutation. The actual before/after slot value and appointment count are checked after the service transaction has finished.

## 2. Report expectation and join cardinality

The tiny disposable fixture contains two veterinarians. Veterinarian `93001` has one seeded appointment; veterinarian `93002` has none. A LEFT JOIN with the date predicate in the `ON` clause preserves both veterinarians. `COUNT(a.appointment_id)` returns 1 and 0 respectively. `COUNT(*)` would count the unmatched parent row as one for veterinarian 93002, so it is not the correct child-count expression. The vaccine report similarly uses `COUNT(vr.pet_id)` so pet `92002` correctly reports zero vaccinations.

The Week 15 appointment view is an inner join because every appointment must reference a pet and veterinarian. Its single test fixture row should show the seeded pet and veterinarian names. A view returning zero rows is not automatically correct; compare its expected appointment ID and values with the base tables.

## 3. Cross-layer diagnosis

A database result must be traced from the form/API input through service code and bound ORM query to the selected schema, MySQL constraint result, response status, and a fresh SQL read. The environment must be checked with `SELECT DATABASE(), USER(), CURRENT_USER()` when a result seems inconsistent. The disposable test schema is named `infoman1_vetclinic_test` so tests cannot silently target the academic finals schema.

A service unit test with mocked repositories can check the business decision but cannot prove a real rollback. The WEBDEV2 MySQL integration case calls the Spring-managed `AppointmentService` without wrapping the test method in `@Transactional`; after the method throws, JDBC reads the slot and appointment state outside the service transaction.

## 4. EXPLAIN and index tradeoff

The verification script runs EXPLAIN for a join filtering appointments by veterinarian and date. Record the actual `key`, `possible_keys`, and estimated `rows`. On the tiny fixture, a table scan can be reasonable because there are very few rows; it is not proof that the query is broken. A candidate composite index is `(vet_id, appointment_date)` because those columns appear together in equality/range predicates. The tradeoff is additional storage and extra index maintenance on appointment inserts/updates/deletes. Do not add it solely because it looks faster on a two-row dataset; compare plans on representative data first.

## 5. Defect and integrity policy

Week 15 work revealed configuration/security issues recorded in `defects.md`. Fixes are accepted only after the relevant case and related regression tests are rerun. Constraints are not removed to make an insert pass, and root privileges are not granted to the runtime user to bypass schema drift.

## 6. Test isolation

All invalid FK, duplicate, range and delete tests belong in `infoman1_vetclinic_test`. The `mysql_test_setup.sql` script creates but never drops that schema. Verify `DATABASE()` before running any test. Do not run the destructive/negative tests against `infoman1_vetclinic_finals`.
