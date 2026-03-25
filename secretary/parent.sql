-- MySQL (Hostinger/phpMyAdmin) schema for parent.html
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS secretary_parents (
    parent_code VARCHAR(30) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    relationship_to_student VARCHAR(80) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    second_guardian_name VARCHAR(150) NULL,
    second_guardian_relationship VARCHAR(80) NULL,
    second_guardian_phone VARCHAR(30) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (parent_code),
    KEY idx_secretary_parents_full_name (full_name),
    KEY idx_secretary_parents_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
