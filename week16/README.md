# INFOMAN1 Week 16 — F4 Verified Database Integration

Continue the Pet Veterinary Clinic project from Week 15. The main production schema remains `infoman1_vetclinic_finals`; Week 16 database experiments should use the separate disposable schema `infoman1_vetclinic_test`.

## Safe execution order

1. Keep the existing Week 13–15 folders unchanged.
2. As a local MySQL administrator, inspect whether `infoman1_vetclinic_test` already exists. Do not drop it if it contains work you need.
3. Run `mysql_test_setup.sql` only against a local development MySQL server. It creates a separate `_test` database and fictional fixtures; it does not drop any database or table. On rerun it resets only the specifically named Week 16 transaction-test appointments and the two dedicated 2099 capacity rows.
4. Review `mysql_test_user_template.sql`, replace password markers in a private copy outside Git, and create the test-only account. Do not commit the private copy.
5. Run `verification.sql` as the authorized local test-schema maintainer. It reads base tables as well as the report view, so do not run the whole file as the report-only identity.
6. Replace password markers in a private copy of `mysql_test_user_template.sql` outside Git, create the two test-only accounts, then run `runtime_privilege_tests.sql` as `capstone_test_app` and `report_privilege_tests.sql` as `capstone_test_report`, each in a fresh session.
7. Execute each numbered block in `constraint_tests.sql` individually; the expected-error statements intentionally stop or report errors in common SQL clients. Run `transaction_verification.sql` as the authorized local test-schema maintainer because it creates and removes a temporary stored procedure.
8. Complete `test_matrix.md`, `lecture.md`, `defects.md`, `checkpoint.md`, and add real screenshots under `evidence/`.

## Database identity

The test database name must be exactly `infoman1_vetclinic_test`. The WEBDEV2 integration test also checks that database name before making any fixture changes. Do not point a test account or integration test at a live or irreplaceable database.

## Test data summary

- Owner `91001`
- Pets `92001` (one vaccination) and `92002` (no appointments or vaccinations; safe delete fixture)
- Veterinarians `93001` and `93002`
- One seeded appointment for `93001`
- Two appointment-capacity rows for dates in 2099 used by integration tests

The fixtures are fictional and intentionally small so expected report totals can be checked manually.
