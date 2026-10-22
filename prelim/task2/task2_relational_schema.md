# Task 2 — Relational Schema

- **STORAGE_LOCATION**(<u>location_code</u>, description)
- **MEMBER**(<u>member_id</u>, member_name, phone, join_date)
- **TOOL**(<u>tool_id</u>, tool_name, category, purchase_date, location_code [FK → STORAGE_LOCATION.location_code])
- **CERTIFICATION**(<u>cert_id</u>, cert_name)
- **BORROWING**(<u>borrow_id</u>, member_id [FK → MEMBER.member_id], tool_id [FK → TOOL.tool_id], borrow_date, return_date)
- **TOOL_REQUIREMENT**(<u>tool_id</u> [FK → TOOL.tool_id], <u>cert_id</u> [FK → CERTIFICATION.cert_id])
  - Composite primary key: (`tool_id`, `cert_id`)
- **MEMBER_CERTIFICATION**(<u>member_id</u> [FK → MEMBER.member_id], <u>cert_id</u> [FK → CERTIFICATION.cert_id], completion_date)
  - Composite primary key: (`member_id`, `cert_id`)

## How the relationships are resolved

1. A storage location may hold zero or more tools. Every tool must reference exactly one storage location, so `TOOL.location_code` is a NOT NULL foreign key.
2. The conceptual MEMBER–TOOL `BORROWS` relationship is many-to-many over time. In the relational design it becomes `BORROWING`, with `borrow_id` as the primary key so a member can borrow the same tool more than once on different occasions. `borrow_date` and `return_date` belong to this table.
3. TOOL–CERTIFICATION `REQUIRES` is many-to-many and becomes `TOOL_REQUIREMENT` with a composite primary key.
4. MEMBER–CERTIFICATION `COMPLETES` is many-to-many and becomes `MEMBER_CERTIFICATION`. Its relationship attribute `completion_date` is stored in the junction table.
5. No separate weak entity or multivalued, composite, or derived attribute is explicitly specified in the scenario.
