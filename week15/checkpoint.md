# INFOMAN1 Week 15 F3 Checkpoint

## Project continuity

- Project: Pet Veterinary Clinic.
- Database: `infoman1_vetclinic_finals`.
- Week 13 schema and seed data remain the baseline.
- Week 14 added `vet_availability` and the atomic appointment workflow.
- Week 15 adds `app_user`, the approved report view, and restricted MySQL identities.
- Shared WEBDEV2 application path: `WEBDEV2/` at the repository root on the `week15` branch. Do not duplicate the application into this repository.
- INFOMAN1 repository path: `week15/`.

## Prerequisites and execution order

1. Existing Week 13 database: `week13/schema.sql`, `week13/seed.sql`, `week13/views.sql` (do not recreate these over populated tables).
2. Week 14 database: `week14/alter_week14.sql` has already installed `vet_availability`.
3. Run `auth_schema.sql` as the local schema maintainer to create `app_user`.
4. Generate two BCrypt hashes with the WEBDEV2 `PasswordHashTool`, then run a local copy of `seed_test_users.template.sql` as the maintainer. Do not commit the local copy.
5. Copy `access_control.sql` outside Git, replace its two password markers with different strong local MySQL account passwords, and run as the authorized administrator.
6. Test `runtime_session_tests.sql` from a fresh `capstone_app` connection.
7. Test `report_session_tests.sql` from a fresh `capstone_report` connection.
8. Follow `revoke_restore_steps.sql`: revoke as administrator, test SELECT denial from a new report connection, restore as administrator, then verify SELECT from another fresh report connection.
9. Configure WEBDEV2 environment variables to use `capstone_app`, not root, and run the Week 15 application tests.

## Runtime configuration names

```text
DB_URL=jdbc:mysql://127.0.0.1:3307/infoman1_vetclinic_finals?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
DB_USERNAME=capstone_app
DB_PASSWORD=<local capstone_app database password>
```

`DB_PASSWORD` is the MySQL runtime-account password. It is not the password for `clinic_manager` or `clinic_reader` in `app_user`.

## Requirement → feature → test/evidence

| Requirement | File / implementation | Test and evidence |
|---|---|---|
| Separate schema maintainer, runtime, and report identities | `access_control.sql`, `permission_matrix.md` | `USER()`, `CURRENT_USER()`, `SHOW GRANTS` for each account |
| Runtime can perform required operations without root | Table-specific grants in `access_control.sql`; WEBDEV2 configured to `capstone_app` | Start app as `capstone_app`; manager pet/appointment CRUD succeeds |
| Runtime cannot change schema | No CREATE/ALTER/DROP grants | `runtime_session_tests.sql` CREATE TABLE denied (expected error 1142) |
| Report reads only approved data | `vw_week15_appointment_report`, SQL SECURITY DEFINER | `SHOW CREATE VIEW`, report SELECT succeeds, no base table grants |
| Report cannot modify base tables | No base-table DML grant | UPDATE statement in `report_session_tests.sql` denied (expected error 1142) |
| REVOKE removes and restore returns the read permission | `revoke_restore_steps.sql` | Fresh report session: SELECT denied after revoke and succeeds after restore |
| Application end-user roles differ from MySQL users | `app_user` schema and WEBDEV2 Spring Security | Manager/Reader authentication and authorization test evidence in WEBDEV2 week15 |

## Actual versus expected results

| Test | Expected | Actual result / evidence |
|---|---|---|
| `capstone_app` identity | CURRENT_USER matches `capstone_app` at `127.0.0.1` | PENDING |
| Runtime CRUD through application | Required pet/appointment operations succeed | PENDING |
| Runtime DDL attempt | Error 1142 / CREATE denied | PENDING |
| `capstone_report` identity | CURRENT_USER matches `capstone_report` at `127.0.0.1` | PENDING |
| Approved view read | SELECT succeeds | PENDING |
| Report base-table write | Error 1142 / UPDATE denied | PENDING |
| Revoked view read | New report session receives SELECT denied | PENDING |
| Restored view read | New report session SELECT succeeds | PENDING |

## Known limitations

- Password markers must be replaced in local copies before provisioning. The committed template is intentionally not runnable as-is.
- `CREATE USER IF NOT EXISTS` does not reset a password on an account that already exists. Inspect existing grants and accounts before rerunning provisioning.
- MySQL privileges are effective only for the matched account; always record `CURRENT_USER()`.
- The local database and screenshots cannot be executed from this package. Replace PENDING only after the tests run on the student's MySQL server.

## Change log

- Added the application-user table needed by WEBDEV2 Week 15 authentication.
- Added table-specific least-privilege runtime grants and a view-only report account.
- Added identity, allowed/denied, revoke, and restore verification scripts.
- Documented the definer-security view and schema/runtime ownership boundary.
