# INFOMAN1 Week 15 — F3 Lecture: Database Accounts and Least Privilege

## 1. Identity boundaries

The Pet Veterinary Clinic has three separate responsibility layers. The schema maintainer is the local database administrator who runs migrations and provisions database accounts. The application runtime account is `capstone_app`@`127.0.0.1`; Spring Boot uses it to perform only the SQL operations required by the clinic features. The reporting account is `capstone_report`@`127.0.0.1`; it can read only the approved report view. People who sign in to the application are not MySQL accounts. Their application roles are stored separately in `app_user`.

A frontend button being hidden is not database security. The database checks the privileges of the connection account for every SQL statement. The application will also enforce its own MANAGER and READER roles in the backend; neither layer replaces the other.

## 2. Least-privilege design

The permissions are listed in `permission_matrix.md`. `capstone_app` can read reference data (`owner`, `veterinarian`, `vaccination_record`), perform CRUD on `pet` and `appointment`, read `app_user` for login, and update/read `vet_availability` for the Week 14 booking transaction. It does not receive CREATE, ALTER, DROP, GRANT, CREATE USER, or other schema-administration privileges. The app currently does not write vaccination records or modify owner/veterinarian reference data, so those grants are not included.

`capstone_report` receives SELECT only on `vw_week15_appointment_report`. It has no direct SELECT or DML grant on `appointment`, `pet`, or `veterinarian`. The report view intentionally omits owner phone numbers. This limits what reporting users can retrieve without granting access to every base table.

The database accounts are scoped to `127.0.0.1`, matching the local TCP connection in `DB_URL`. A wildcard `%` host would accept connections from a broader set of hosts and is unnecessary for this local assessment. `CREATE USER IF NOT EXISTS` avoids silently replacing an existing account; it does not reset its password. Existing accounts must be inspected with `SHOW GRANTS` before any manual password change.

## 3. View security context

`vw_week15_appointment_report` is created by the administrator with `SQL SECURITY DEFINER`. MySQL checks the definer's required privileges on the underlying tables when the report user selects the view. The report user needs SELECT on the view, not direct SELECT on the base tables. `SHOW CREATE VIEW` is the evidence for the configured security context. If the view were `SQL SECURITY INVOKER`, the report account would need the underlying table permissions, which would weaken the intended restriction.

The definer account must remain valid and retain the necessary underlying privileges. Do not create the view as the restricted reporting user.

## 4. Verification method

Every privilege test uses a fresh connection as the account being tested. `USER()` reports the client identity, while `CURRENT_USER()` reports the MySQL account that matched the connection and whose privileges are effective. `SHOW GRANTS` is inspected in each session.

As `capstone_app`, the application must continue to perform normal pet and appointment operations. A harmless CREATE TABLE attempt must fail with an access-denied error because the runtime account is not a schema maintainer. As `capstone_report`, SELECT from the approved view should work and UPDATE against the appointment base table should fail. The report SELECT grant is then revoked, tested from a new report connection, and restored. A successful post-restore SELECT proves the grant was restored.

## 5. Diagnosis and secret handling

A common least-privilege failure is application startup failing because Hibernate tries to alter the schema. The correct fix is not to grant ALTER to the runtime identity. The Week 14 configuration already uses `spring.jpa.hibernate.ddl-auto=validate`, so a schema maintainer installs `app_user` and the report view before the application starts. The runtime account then validates mappings and performs DML only.

The provisioning SQL contains password markers by design. Replace them only in a local, untracked copy with different strong values. Application-user password hashes are generated with WEBDEV2's BCrypt helper and inserted into `app_user` by the administrator. Do not commit local provisioning files, plaintext passwords, BCrypt hashes, `.env` files, tokens, or screenshots that reveal credentials.

## 6. Project-specific acceptance statement

This design is intended to let the existing Week 14 application run as `capstone_app`, not root, while a separate report user reads one approved view. Actual success and denial outcomes must be recorded in `checkpoint.md` only after the local MySQL tests have been executed.
