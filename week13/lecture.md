# INFOMAN1 — Week 13 F1 Lecture

## 1. Six testable requirements

1. The database shall store each pet owner with a unique owner ID, first name, last name, and phone number.
2. Each pet shall store a unique required microchip number, name, species, breed, age, and the ID of exactly one owner.
3. The database shall store veterinarians with their name and specialization.
4. Every appointment shall reference exactly one existing pet and one existing veterinarian, plus an appointment date and reason.
5. A pet may have zero or many vaccination records; each vaccination record shall be identified by its pet ID, vaccine name, and vaccination date.
6. The shared application shall display actual pet and appointment information from MySQL, and a join-based SQL view shall report appointments with their pet, owner, and veterinarian.

## 2. Baseline audit

Existing INFOMAN1 files from earlier work describe the veterinary-clinic domain. The Week 3 ERD defined owner, pet, veterinarian, appointment, and a weak vaccination-record entity. The Week 4 DDL created the five related tables, but it had no sample-data/view/application-read evidence for this F1 checkpoint. The supplied WEBDEV2 Week 8 project already has a Pet entity, repository, service, CRUD/search endpoints, and unique required microchip mapping. Its Week 8 datasource, however, targets a separate MariaDB `webdev2_week8` database. F1 aligns the two sides to the single shared MySQL schema `infoman1_vetclinic_finals`.

| Area | Baseline state | F1 action |
|---|---|---|
| Logical veterinary clinic ERD | Existing from Week 3 | Preserve and extend Pet with required microchip and breed from WEBDEV2 Pet model |
| Five core domain tables | Existing Week 4 DDL | Provide one reproducible shared MySQL schema with InnoDB, PKs, FKs, UNIQUE, NOT NULL, and CHECK |
| Deterministic data | Incomplete for F1 | Add linked fictional seed rows |
| Joined SQL report | Not present in earlier Week 4 DDL | Add appointment and vaccination-history views |
| Application read from shared MySQL | Not proven by the uploaded Week 8 configuration | WEBDEV2 F1 connects its API to this shared schema; capture actual browser/API/SQL comparison |

## 3. ERD and relationships

See `erd.md`. The project has five related domain tables: `owner`, `pet`, `veterinarian`, `appointment`, and `vaccination_record`. The physical `owner` table represents the logical `pet_owner` entity. Every FK is documented in the ERD and declared in `schema.sql`.

## 4. Functional dependency and anomaly prevention

`owner_id -> first_name, last_name, phone_number` is a functional dependency. The owner ID determines the owner's contact details. The pet table stores only `owner_id` as a foreign key instead of repeating the owner's name and phone number for every pet. If an owner changes a phone number, the clinic updates one owner row. This prevents an update anomaly caused by repeating the same owner contact values in several pet rows.

Other dependencies include `pet_id -> microchip_number, name, species, breed, age, owner_id` and `appointment_id -> appointment_date, reason_for_visit, pet_id, vet_id`.

## 5. View versus table

A normal SQL view stores a SELECT definition, not a duplicate copy of all result rows. `vw_appointment_overview` joins appointment, pet, owner, and veterinarian. It reads current values from those base tables when queried. `vw_pet_vaccination_history` uses a LEFT JOIN so pets without vaccination records can still appear. CRUD writes should target base tables; a join view is mainly a reusable read/report surface and is not automatically updatable.

## 6. Application read trace

The shared WEBDEV2 application serves the browser interface. JavaScript requests `GET /api/v1/pets?page=0&size=10`; Spring Boot calls `PetReadController`, then `PetReadService`, then Spring Data repositories, which query the MySQL `pet` and `owner` tables. The service maps results into a DTO and Spring returns JSON with a paginated `content` array. The browser renders the pet rows. Selecting a pet calls `GET /api/v1/pets/{id}`, which also reads the selected pet's appointment and vaccination records. The backend, not browser JavaScript, holds database credentials.

Before submission, replace this designed trace with one actual pet ID and compare its UI/API values to SQL results. Save the real screenshots and outputs in `evidence/`.

## 7. Connection secrets

Host, port, schema name, username, and password are configured in the Spring Boot backend using local environment variables. Real passwords and `.env` files are excluded from Git. A browser can expose its JavaScript and network traffic, so a MySQL password must never be stored in frontend code.
