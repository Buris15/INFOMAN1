# Week 15 Permission Matrix — Pet Veterinary Clinic

The schema maintainer uses the local administrative account only for schema setup, migrations, creating database accounts, creating the approved report view, and grants. It is never configured in the browser or normal application runtime.

| Database object | Maintainer | `capstone_app` runtime | `capstone_report` |
|---|---|---|---|
| `owner` | Administrative | SELECT | No access |
| `veterinarian` | Administrative | SELECT | No access |
| `pet` | Administrative | SELECT, INSERT, UPDATE, DELETE | No access |
| `appointment` | Administrative | SELECT, INSERT, UPDATE, DELETE | No access |
| `vaccination_record` | Administrative | SELECT | No access |
| `vet_availability` | Administrative | SELECT, UPDATE | No access |
| `app_user` | Administrative | SELECT only | No access |
| `vw_week15_appointment_report` | Administrative | Not required by the current app | SELECT only |
| CREATE / ALTER / DROP schema objects | Yes | Denied | Denied |
| GRANT / REVOKE / CREATE USER | Yes | Denied | Denied |

## Host scope

Both MySQL accounts are provisioned as `@'127.0.0.1'` because the current Spring datasource and local CLI examples connect over TCP to `127.0.0.1:3307`. This is narrower and more explicit than a wildcard host. Verify the matched identity with `CURRENT_USER()` in each fresh session; do not assume the host match.

## Application users versus database users

`clinic_manager` and `clinic_reader` are rows in `app_user`; they sign in to the web application. `capstone_app` and `capstone_report` are MySQL connection accounts. They are different identities and use separate passwords. The runtime account can read `app_user` to authenticate but cannot insert, update, or delete user accounts.
