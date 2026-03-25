-- MySQL (Hostinger/phpMyAdmin) schema for student.html
SET NAMES utf8mb4;

-- Dependency table used by student parent reference.
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

CREATE TABLE IF NOT EXISTS secretary_students (
    student_id VARCHAR(30) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    gender ENUM('male', 'female') NOT NULL,
    date_of_birth DATE NOT NULL,
    class_grade VARCHAR(60) NOT NULL,
    parent_code VARCHAR(30) NOT NULL,
    admission_date DATE NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id),
    KEY idx_secretary_students_full_name (full_name),
    KEY idx_secretary_students_class_grade (class_grade),
    KEY idx_secretary_students_parent_code (parent_code),
    CONSTRAINT fk_secretary_students_parent
        FOREIGN KEY (parent_code)
        REFERENCES secretary_parents(parent_code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
