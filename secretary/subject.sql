-- MySQL (Hostinger/phpMyAdmin) schema for subject.html
SET NAMES utf8mb4;

-- Dependencies for dropdown references.
CREATE TABLE IF NOT EXISTS secretary_classes (
    class_code VARCHAR(30) NOT NULL,
    class_grade VARCHAR(80) NOT NULL,
    section VARCHAR(20) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (class_code),
    UNIQUE KEY uq_secretary_classes_grade_section (class_grade, section)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS secretary_departments (
    department_code VARCHAR(30) NOT NULL,
    department_name VARCHAR(120) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (department_code),
    UNIQUE KEY uq_secretary_departments_name (department_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS secretary_subjects (
    subject_code VARCHAR(30) NOT NULL,
    subject_name VARCHAR(120) NOT NULL,
    class_code VARCHAR(30) NOT NULL,
    grade_level VARCHAR(60) NULL,
    department_code VARCHAR(30) NOT NULL,
    maximum_mark DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (subject_code),
    KEY idx_secretary_subjects_name (subject_name),
    KEY idx_secretary_subjects_class_code (class_code),
    KEY idx_secretary_subjects_department_code (department_code),
    CONSTRAINT fk_secretary_subjects_class
        FOREIGN KEY (class_code)
        REFERENCES secretary_classes(class_code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_secretary_subjects_department
        FOREIGN KEY (department_code)
        REFERENCES secretary_departments(department_code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
