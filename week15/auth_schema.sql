-- INFOMAN1 / WEBDEV2 Week 15 F3
-- Run once as an authorized schema maintainer before creating application test users.
-- This is an additive schema change. It does not drop or alter Week 13/14 objects.
USE infoman1_vetclinic_finals;

CREATE TABLE IF NOT EXISTS app_user (
    user_id BIGINT NOT NULL AUTO_INCREMENT,
    username VARCHAR(60) NOT NULL,
    password_hash VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL,
    enabled TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_app_user PRIMARY KEY (user_id),
    CONSTRAINT uk_app_user_username UNIQUE (username),
    CONSTRAINT chk_app_user_role CHECK (role IN ('MANAGER', 'READER'))
) ENGINE=InnoDB;

DESCRIBE app_user;
