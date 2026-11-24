# INFOMAN1 Week 15 Security Test Matrix

| ID | Session / identity | Action | Expected result | Actual result |
|---|---|---|---|---|
| DB-01 | Administrator | `SHOW GRANTS FOR 'capstone_app'@'127.0.0.1'` | Only table-specific runtime grants | PENDING |
| DB-02 | Administrator | `SHOW GRANTS FOR 'capstone_report'@'127.0.0.1'` | SELECT on report view only | PENDING |
| DB-03 | `capstone_app` | Read pet, appointment, and schedule rows | Success | PENDING |
| DB-04 | `capstone_app` | CREATE test table | Denied, error 1142 | PENDING |
| DB-05 | `capstone_report` | SELECT approved report view | Success | PENDING |
| DB-06 | `capstone_report` | UPDATE base appointment table with `WHERE 1=0` | Denied, error 1142 | PENDING |
| DB-07 | Administrator + fresh report session | REVOKE view SELECT, then SELECT | Denied | PENDING |
| DB-08 | Administrator + fresh report session | Restore view SELECT, then SELECT | Success | PENDING |

Record actual status, timestamp, `CURRENT_USER()`, and the evidence filename after executing each case.
