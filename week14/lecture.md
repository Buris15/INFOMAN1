# INFOMAN1 — Week 14 F2 Lecture

## 1. Week 13 continuity and Week 14 change

The project remains the Pet Veterinary Clinic. Week 13's `owner`, `pet`, `veterinarian`, `appointment`, and `vaccination_record` tables, their keys, constraints, seed records, and join views are retained. Week 14 adds `vet_availability` so an appointment booking changes a real capacity record as well as creating an appointment. The change is additive; the Week 13 schema is not dropped or rebuilt.

## 2. Two-resource CRUD and integrity rules

The shared application provides CRUD through its API for the two principal resources: `pet` and `appointment`. Pet creation, read, update, and delete operate on the base `pet` table. An owner choice must reference an existing `owner.owner_id`. The microchip number remains unique and age cannot be negative. Deleting a pet that is referenced by an appointment or vaccination record is rejected by the foreign key and returned as a conflict instead of deleting clinic history.

Appointment creation is not a direct insert-only operation. It is the booking workflow: the application checks the selected veterinarian/date capacity, decrements one available slot, then inserts the appointment. Appointment update can move the booking to another veterinarian/date; in one transaction it reserves the new slot and releases the old one. Appointment cancellation deletes the appointment and restores its slot atomically. All database writes use ORM-bound values; browser-supplied IDs select existing records but do not establish trusted capacity.

## 3. Business invariant and transaction boundary

**Invariant:** for every `(vet_id, availability_date)`, `0 <= available_slots <= total_slots`; each committed appointment booking consumes one available slot, and each committed cancellation releases one previously consumed slot.

The transaction begins inside the application service method `AppointmentService.bookAppointment`. The service obtains a pessimistic write lock on the `vet_availability` row, checks capacity, decrements the count, inserts the appointment, and commits only when both writes succeed. A failure after the decrement causes the method to throw and Spring rolls the transaction back. `AppointmentService.cancelAppointment` similarly restores capacity and deletes the appointment before commit. The controller calls the public service method through Spring's proxy; the `@Transactional` annotation is not relied on through self-invocation.

The SQL migration uses InnoDB. The API does not expose MySQL credentials to JavaScript. It sends one request to one business endpoint; the browser does not split booking into two independent writes.

## 4. ACID as applied to appointment booking

- **Atomicity:** reserving a slot and inserting an appointment both commit, or neither change remains. The forced invalid-pet test causes a failure after the first database write and verifies the slot count returns to its before-state.
- **Consistency:** foreign keys require an existing pet and veterinarian. CHECK constraints keep slot counts within their permitted range. The service checks that at least one slot remains before decrementing.
- **Isolation:** `SELECT ... FOR UPDATE` behavior is provided by the JPA repository's `PESSIMISTIC_WRITE` lock. Two requests competing for the last slot cannot both decrement the same previously read value.
- **Durability:** after commit, both the new appointment and updated availability can be read from a separate MySQL connection. The Week 14 success script records the committed appointment ID and queries both affected tables.

ACID depends on correct transaction placement and database engine settings. A transaction does not make an incorrect invariant correct by itself.

## 5. Full rollback versus savepoint rollback

The controlled failure procedure decrements availability and then attempts to insert an appointment with a nonexistent pet foreign key. Its exception handler rolls back the complete transaction. Expected evidence is that the slot count is unchanged and no failed appointment row exists.

The savepoint exercise reserves one slot and inserts a valid appointment, then creates `SAVEPOINT after_appointment_insert`. It changes the appointment reason and executes `ROLLBACK TO SAVEPOINT`. The reason update is undone, but the earlier appointment insert and capacity decrement are still present inside the open transaction. The final `ROLLBACK` then removes the appointment and restores the original capacity. A savepoint is a partial rollback marker, not a commit.

## 6. Concurrency risk and control

A race is possible if two booking requests both read `available_slots = 1` using an ordinary unlocked SELECT and each later decrements it. The project controls this by selecting the schedule row with a pessimistic write lock before checking and changing it. A competing transaction waits for the row lock and then reads the remaining committed value. The migration's CHECK constraint is a further database guard against invalid counts. Transactions are kept short; a user never holds a database lock while filling the browser form.

When an appointment is moved between schedule rows, the service locks old and new `(vet_id, date)` keys in a stable date/ID order to reduce deadlock risk. It reserves the destination before releasing the original slot. If either update or the appointment write fails, the whole transaction rolls back.

## 7. Execution and evidence

Run `week13/schema.sql`, `week13/seed.sql`, and `week13/views.sql` only when preparing a clean project schema; then run `week14/alter_week14.sql` and `week14/verify_week14.sql`. Run the separate sections of `week14/transactions.sql` and record actual outputs. Capture before-state, the booking operation, after-state from another connection, controlled rollback, and savepoint partial/full rollback results. The WEBDEV2 service implementation and API request/response provide the application-level transaction path; the SQL file separately demonstrates the underlying transaction behavior.
