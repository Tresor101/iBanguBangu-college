-- MySQL (Hostinger/phpMyAdmin) schema for class-grade.html
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS secretary_classes (
    class_code VARCHAR(30) NOT NULL,
    class_grade VARCHAR(80) NOT NULL,
    section VARCHAR(20) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (class_code),
    UNIQUE KEY uq_secretary_classes_grade_section (class_grade, section),
    KEY idx_secretary_classes_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
