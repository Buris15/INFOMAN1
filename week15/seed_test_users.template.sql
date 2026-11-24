-- COPY this file to seed_test_users.local.sql OUTSIDE the Git repository.
-- Generate each BCrypt hash with the WEBDEV2 PasswordHashTool.
-- Replace both markers with BCrypt hashes. Never use plaintext passwords here.
-- Run as the schema maintainer. Do not grant the runtime account INSERT on app_user.
USE infoman1_vetclinic_finals;

INSERT INTO app_user (username, password_hash, role, enabled)
VALUES
    ('clinic_manager', 'PASTE_MANAGER_BCRYPT_HASH_HERE', 'MANAGER', 1),
    ('clinic_reader',  'PASTE_READER_BCRYPT_HASH_HERE',  'READER', 1);

SELECT user_id, username, role, enabled, created_at
FROM app_user
ORDER BY user_id;
