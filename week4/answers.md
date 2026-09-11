# Lab 4: DDL & Table Creation Documentation

## Task 4: Schema Verification
*   **owner:** The actual structure matches the logical design. The primary key (`owner_id`) is correctly set, and VARCHAR is used for names.
*   **pet:** Matches the intended design. The `owner_id` foreign key properly links back to the `owner` table.
*   **veterinarian:** Matches the intended design.
*   **appointment:** Successfully resolves the many-to-many relationship between pets and veterinarians using foreign keys (`pet_id` and `vet_id`). 
*   **vaccination_record:** Correctly implemented as a weak entity/dependent table linked to `pet` via `pet_id`.

## Task 5: Deliberate Mistake, Diagnosis & Correction
**The Mistake:** 
When creating the `owner` table, I deliberately set the `phone` column data type to `INT`. This is a mistake because phone numbers often contain formatting characters (like + or -) and leading zeros which integers drop.

**The Diagnosis:** 
Running `DESCRIBE owner;` revealed the column definition was incorrect:
`phone | int | YES | | NULL |`

**The Correction:** 
I used the following ALTER TABLE statement to change the column to a string type that can safely hold phone numbers:
`ALTER TABLE owner MODIFY COLUMN phone VARCHAR(20);`

Running `DESCRIBE owner;` again confirmed the type was successfully changed to `varchar(20)`.