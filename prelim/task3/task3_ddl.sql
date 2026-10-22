-- INFOMAN1 Prelim Lab Exam: TaskShare / ToolShare database
-- Task 3: MySQL DDL. Run this before importing toolshare_sample_data.sql.
-- The instructor-provided sample script uses the same table names and columns.

CREATE DATABASE IF NOT EXISTS toolshare_prelim;
USE toolshare_prelim;

CREATE TABLE IF NOT EXISTS storage_location (
    location_code VARCHAR(10) NOT NULL,
    description VARCHAR(100) NOT NULL,
    PRIMARY KEY (location_code)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS member (
    member_id INT NOT NULL,
    member_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    join_date DATE NOT NULL,
    PRIMARY KEY (member_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tool (
    tool_id INT NOT NULL,
    tool_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    purchase_date DATE NOT NULL,
    location_code VARCHAR(10) NOT NULL,
    PRIMARY KEY (tool_id),
    CONSTRAINT fk_tool_storage_location
        FOREIGN KEY (location_code)
        REFERENCES storage_location (location_code)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS certification (
    cert_id INT NOT NULL,
    cert_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (cert_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tool_requirement (
    tool_id INT NOT NULL,
    cert_id INT NOT NULL,
    PRIMARY KEY (tool_id, cert_id),
    CONSTRAINT fk_tool_requirement_tool
        FOREIGN KEY (tool_id) REFERENCES tool (tool_id),
    CONSTRAINT fk_tool_requirement_certification
        FOREIGN KEY (cert_id) REFERENCES certification (cert_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS member_certification (
    member_id INT NOT NULL,
    cert_id INT NOT NULL,
    completion_date DATE NOT NULL,
    PRIMARY KEY (member_id, cert_id),
    CONSTRAINT fk_member_certification_member
        FOREIGN KEY (member_id) REFERENCES member (member_id),
    CONSTRAINT fk_member_certification_certification
        FOREIGN KEY (cert_id) REFERENCES certification (cert_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS borrowing (
    borrow_id INT NOT NULL,
    member_id INT NOT NULL,
    tool_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    return_date DATE NULL,
    PRIMARY KEY (borrow_id),
    CONSTRAINT fk_borrowing_member
        FOREIGN KEY (member_id) REFERENCES member (member_id),
    CONSTRAINT fk_borrowing_tool
        FOREIGN KEY (tool_id) REFERENCES tool (tool_id)
) ENGINE=InnoDB;

-- Verification commands: run these one at a time in phpMyAdmin.
SHOW TABLES;
DESCRIBE storage_location;
DESCRIBE member;
DESCRIBE tool;
DESCRIBE certification;
DESCRIBE borrowing;
DESCRIBE tool_requirement;
DESCRIBE member_certification;
