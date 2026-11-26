# INFOMAN1 Week 16 Test Matrix

**Project:** Pet Veterinary Clinic  
**Production academic schema:** `infoman1_vetclinic_finals` (do not use for destructive tests)  
**Disposable test schema:** `infoman1_vetclinic_test`  
**Test source:** scripts in this folder and WEBDEV2 Week 16 MySQL integration cases.  
**Status convention:** `PENDING` until run; replace with actual observed output and evidence file path.

| ID | Requirement | Preconditions / exact input | Expected result | Actual / status | Evidence |
|---|---|---|---|---|---|
| IF16-01 | Correct target and account identity | Connect to `infoman1_vetclinic_test`; run identity query in `verification.sql` | Database name is exactly `_test`; record `USER()` and `CURRENT_USER()` | PENDING | `evidence/01_test_identity.png` |
| IF16-02 | Test schema reconstructed | Run `mysql_test_setup.sql`; inspect table list and fixture counts | Six domain tables plus `app_user`; owner=1, vets=2, pets=2, appointment=1, vaccine=1, availability=2 | PENDING | `evidence/02_test_schema_seed.png` |
| IF16-03 | Valid create | In test DB, run CT-01 first INSERT with owner 91001 | One temporary pet inserted and can be selected | PENDING | `evidence/03_valid_create.png` |
| IF16-04 | List/detail read | Query `pet` and filter `pet_id=92001` | Seeded pet details returned | PENDING | `evidence/04_pet_read.png` |
| IF16-05 | Valid update | CT-01 update temporary pet name | Updated name visible before rollback | PENDING | `evidence/05_valid_update.png` |
| IF16-06 | Valid delete policy | Delete fixture 92002 in a transaction; it has no related history | One row deleted inside transaction; rollback restores fixture | PENDING | `evidence/06_valid_delete.png` |
| IF16-07 | Range constraint | Insert pet with age -1 | MySQL CHECK constraint rejects insert; no persistent row | PENDING | `evidence/07_invalid_age.png` |
| IF16-08 | Unique constraint | Insert duplicate `W16-MC-92001` | Duplicate-key error; existing pet unchanged | PENDING | `evidence/08_duplicate_chip.png` |
| IF16-09 | FK constraint | Insert pet with owner_id 99999999 | FK violation; no persistent row | PENDING | `evidence/09_invalid_owner_fk.png` |
| IF16-10 | Joined/view report | Run report query and LEFT JOIN aggregation in `verification.sql` | One seeded view row; vet 93001 count=1 and vet 93002 count=0; vaccine counts 1 and 0 | PENDING | `evidence/10_report_expected_values.png` |
| IF16-11 | Successful atomic transaction | Run TX-01 in `transaction_verification.sql` | One slot consumed and one matching appointment committed | PENDING | `evidence/11_commit_before_after.png` |
| IF16-12 | Rollback after first write | Run TX-02; invalid pet FK occurs after slot update | Available slots return to before-state; failed appointment count=0 | PENDING | `evidence/12_rollback_before_after.png` |
| IF16-13 | Runtime schema denial | Run `runtime_privilege_tests.sql` in a fresh `capstone_test_app` session; attempt CREATE TABLE | Error 1142; no table created | PENDING | `evidence/13_runtime_ddl_denied.png` |
| IF16-14 | Report base-table denial | Run `report_privilege_tests.sql` in a fresh `capstone_test_report` session; attempt safe `UPDATE appointment SET reason_for_visit=reason_for_visit WHERE 1=0` | Error 1142; no data changed | PENDING | `evidence/14_report_write_denied.png` |
| IF16-15 | Query-plan inspection | Run final EXPLAIN in `verification.sql` | Record chosen key / table scan and reason; no unsupported speed claim | PENDING | `evidence/15_explain.png` |

## Evidence rules

- Capture SQL statement and output together when possible.
- For expected-error tests, capture the actual MySQL error and the follow-up count query proving no row persisted.
- Use only `infoman1_vetclinic_test` for invalid and destructive tests.
- A test is not PASS until it has an actual result and evidence path.
