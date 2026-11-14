# Application ↔ MySQL read comparison (fill after actual run)

- Browser URL:
- Selected pet ID:
- API endpoint:
- HTTP status:
- Pet name/species/breed/microchip shown in browser:
- Owner shown in browser:
- Appointment and vaccination values shown:

SQL query used:

```sql
SELECT p.pet_id, p.microchip_number, p.name, p.species, p.breed, p.age,
       CONCAT(o.first_name, ' ', o.last_name) AS owner_name
FROM pet AS p
JOIN owner AS o ON o.owner_id = p.owner_id
WHERE p.pet_id = <PET_ID>;
```

Actual SQL result:

- Paste or attach the real output.
- Confirm each displayed value matches the SQL result.
- Screenshot filename:
