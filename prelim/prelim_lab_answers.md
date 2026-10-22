# INFOMAN1 — Prelim Lab Exam Answers

## Task 1 — Conceptual ERD

The conceptual ERD contains four core entities: **Member**, **Tool**, **Certification**, and **Storage Location**. Primary/key attributes are identified in the diagram.

### Relationships and cardinalities

- **Storage Location — STORES — Tool:** one storage location can hold zero or many tools; every tool belongs to exactly one storage location (mandatory on the Tool side).
- **Member — BORROWS — Tool:** many-to-many over time. A member may borrow multiple tools, and a tool may be borrowed by different members. `borrow_date` and `return_date` are attributes of this borrowing event/relationship. A NULL `return_date` means the tool is currently recorded as on loan.
- **Tool — REQUIRES — Certification:** many-to-many; a tool may require multiple certifications and a certification may apply to multiple tools.
- **Member — COMPLETES — Certification:** many-to-many; `completion_date` is an attribute of this relationship.

The conceptual ERD keeps the M:N relationships unresolved, as required. The specification does not identify any multivalued, composite, or derived attributes.

## Task 2 — Logical ERD and relational schema

The logical ERD resolves the many-to-many relationships with two junction tables: `tool_requirement` and `member_certification`. The Member–Tool borrowing relationship becomes the `borrowing` transaction table. It uses `borrow_id` as a primary key because a member may borrow the same tool on more than one occasion.

The complete notation is in `task2_relational_schema.md`. Composite primary keys are used in `tool_requirement` (`tool_id`, `cert_id`) and `member_certification` (`member_id`, `cert_id`). The `completion_date` attribute belongs in `member_certification`; `borrow_date` and `return_date` belong in `borrowing`.

## Task 3 — MySQL DDL implementation

Run `task3_ddl.sql` to create the database and seven tables, then import/run `toolshare_sample_data.sql` to populate them with the instructor-provided sample data.

### Data type choices

- `phone VARCHAR(20)`: phone numbers are identifiers, not quantities for arithmetic. VARCHAR preserves a leading zero and can accommodate symbols such as `+`.
- `location_code VARCHAR(10)`: codes such as `A3`, `B1`, and `C2` contain letters and numbers, so an integer type is unsuitable.
- `join_date`, `purchase_date`, `borrow_date`, `return_date`, and `completion_date` use `DATE` so MySQL can compare dates correctly. `return_date` is nullable because an active borrowing may not have been returned yet.
- ID fields use `INT` because the supplied sample data uses whole-number identifiers.

`NOT NULL` on `tool.location_code` enforces the requirement that every tool has a storage location. Foreign keys enforce references to valid parent records. The certification eligibility rule is represented by `tool_requirement` and `member_certification`; fully enforcing that cross-table rule at insert time would require an additional trigger or application-level validation, which is not included in the supplied schema script.

### DESCRIBE verification

`task3_describe_output.txt` is a reference checklist of the expected columns/types/key roles derived from the DDL. Run all seven `DESCRIBE` statements locally and compare your actual MySQL/phpMyAdmin output before submission; server versions may format the Default column differently.

## Task 4 — Sample data queries

The five required queries are in `task4_queries.sql`, with expected result rows included as SQL comments. Against the supplied sample data, the expected row counts are:

1. Power Tools: **3 rows**.
2. Members joined after `2025-01-01`: **4 rows**.
3. Borrowings with `return_date IS NULL`: **2 rows**.
4. Borrowings for `member_id = 1` (Maria Santos): **2 rows**.
5. Tools purchased before `2024-01-01`: **3 rows**.

The queries use quoted string/date literals and `IS NULL` for NULL checking.

## Task 5 — Cross-week mismatch

The instructor's query is:

```sql
SELECT borrow_date, return_date
FROM borrowing
WHERE member_name = 'Maria Santos';
```

It fails because `member_name` is not a column in `borrowing`. In the relational schema, names belong to the `member` table. The `borrowing` table stores only `member_id` as a foreign key linking each borrowing event to the member who borrowed the tool.

### Corrected single-table queries

First, find Maria Santos's ID:

```sql
SELECT member_id, member_name
FROM member
WHERE member_name = 'Maria Santos';
```

The supplied sample data returns `member_id = 1`.

Then filter the borrowing table using that ID:

```sql
SELECT borrow_date, return_date
FROM borrowing
WHERE member_id = 1
ORDER BY borrow_date;
```

This returns two records: `2025-09-01` to `2025-09-10`, and `2025-09-12` with a NULL return date.

### Week concepts demonstrated

- **Week 3 — Relational schema and foreign keys:** attributes belong to their designed table; `member_name` is stored in `member`, while `borrowing` references the member by `member_id`.
- **Week 4 — DDL and table implementation:** the actual `borrowing` table has `borrow_id`, `member_id`, `tool_id`, `borrow_date`, and `return_date`; it does not define `member_name`.
- **Week 5 — SELECT and WHERE:** the WHERE condition can only filter on columns available to that query's table scope. The correct workflow is to query `member` by name, then query `borrowing` by the returned ID. This meets the instruction to use single-table SELECT statements rather than JOINs.

## Task 6 — Video walkthrough checklist

Show the conceptual ERD, logical ERD, relational schema, `SHOW TABLES`, `DESCRIBE` for all seven tables, the five Task 4 queries with results, then the original broken Task 5 query and the two corrected queries. Explain the cardinalities, junction tables, primary/foreign keys, data type choices, WHERE filters, and why `member_name` is not a column in `borrowing`.
