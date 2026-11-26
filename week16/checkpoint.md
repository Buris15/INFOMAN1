# INFOMAN1 Week 16 F4 Checkpoint

## Project continuity

- Project: Pet Veterinary Clinic.
- Academic shared schema: `infoman1_vetclinic_finals`.
- Dedicated disposable verification schema: `infoman1_vetclinic_test`.
- Prior folders preserved: `week13/`, `week14/`, `week15/`.
- Shared WEBDEV2 repository: `webdev2` branch `week16`, application at repository root.
- INFOMAN1 repository path: `week16/`.

## Execution order

1. Confirm existing Week 13–15 objects in the academic schema; do not recreate them.
2. Create `infoman1_vetclinic_test` using `mysql_test_setup.sql` as the authorized local maintainer.
3. Create the restricted test-only MySQL runtime user with a private copy of `mysql_test_user_template.sql`.
4. Run `verification.sql`, `constraint_tests.sql`, and `transaction_verification.sql` against the test schema.
5. Run WEBDEV2 service/API tests and the opt-in actual MySQL transaction test with `MYSQL_IT_*` values pointing only to the test schema.
6. Fill every actual result, evidence file path, date, MySQL version, and tested Git branch below.

## Requirement → artifact → test

| Requirement | Artifact | Verification |
|---|---|---|
| Dedicated isolated test data | `mysql_test_setup.sql` | `DATABASE()` exactly equals `infoman1_vetclinic_test` |
| CRUD and FK/unique/check integrity | `constraint_tests.sql` | IF16-03 through IF16-09 |
| Correct report values including zero children | `verification.sql` | IF16-10; compare veterinarian and vaccination counts |
| Query plan diagnosis | `verification.sql` EXPLAIN | IF16-15; record actual key/rows |
| Atomic commit and rollback | `transaction_verification.sql` and WEBDEV2 MySQL integration test | IF16-11/12 |
| Least-privilege regression | Week 15 access scripts against isolated test accounts | IF16-13/14 |

## Environment record (complete locally)

- MySQL version: PENDING
- MySQL port: PENDING
- Test database: `infoman1_vetclinic_test`
- Test account identity (`CURRENT_USER()`): PENDING
- WEBDEV2 branch: `week16` (after branch creation)
- WEBDEV2 application path: repository root (`WEBDEV2/` in supplied archive)
- Test date: PENDING

## Actual results

All cases in `test_matrix.md` start as PENDING. Replace a status only after execution. Keep expected and actual values separate. Do not claim success from a script being present.

## Known limitations

- The local MySQL test database and account provisioning must be executed on the student's computer.
- The two MySQL integration tests are opt-in and require `RUN_MYSQL_IT=true` plus a URL whose schema is exactly `infoman1_vetclinic_test`.
- The test schema is intentionally small; EXPLAIN can select a scan for a tiny row count.
- Prior Week 13–15 screenshots and folders should remain unchanged.
