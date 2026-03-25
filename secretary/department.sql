-- MySQL (Hostinger/phpMyAdmin) schema for department.html
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS secretary_departments (
    department_code VARCHAR(30) NOT NULL,
    department_name VARCHAR(120) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (department_code),
    UNIQUE KEY uq_secretary_departments_name (department_name),
    KEY idx_secretary_departments_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
