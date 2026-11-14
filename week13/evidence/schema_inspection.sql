USE infoman1_vetclinic_finals;

SELECT VERSION() AS mysql_server_version;
SHOW TABLES;
SHOW CREATE TABLE owner;
SHOW CREATE TABLE veterinarian;
SHOW CREATE TABLE pet;
SHOW CREATE TABLE appointment;
SHOW CREATE TABLE vaccination_record;

SELECT 'owner' AS table_name, COUNT(*) AS row_count FROM owner
UNION ALL SELECT 'veterinarian', COUNT(*) FROM veterinarian
UNION ALL SELECT 'pet', COUNT(*) FROM pet
UNION ALL SELECT 'appointment', COUNT(*) FROM appointment
UNION ALL SELECT 'vaccination_record', COUNT(*) FROM vaccination_record;
