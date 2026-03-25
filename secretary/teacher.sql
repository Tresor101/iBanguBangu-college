-- MySQL (Hostinger/phpMyAdmin) schema for teacher.html
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS secretary_teachers (
    teacher_code VARCHAR(30) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (teacher_code),
    KEY idx_secretary_teachers_full_name (full_name),
    KEY idx_secretary_teachers_phone (phone),
    KEY idx_secretary_teachers_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
