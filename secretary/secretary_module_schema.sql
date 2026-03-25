-- Hostinger-compatible schema (MySQL 8 / MariaDB) for:
-- - secretary/student.html
-- - secretary/parent.html
-- - secretary/teacher.html
-- - secretary/dashboard.html
--
-- Features:
-- - Store registrar-created student records
-- - Store parent/guardian records and link to students
-- - Store teacher records (with password hash)
-- - Support dashboard stats for admissions, records updates, and document requests

SET NAMES utf8mb4;

-- --------------------------------------------------
-- Core registration tables
-- --------------------------------------------------

CREATE TABLE IF NOT EXISTS registrar_parents (
    parent_id VARCHAR(30) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    relationship_to_student VARCHAR(80) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (parent_id),
    KEY idx_registrar_parents_full_name (full_name),
    KEY idx_registrar_parents_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS registrar_students (
    student_id VARCHAR(30) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender ENUM('male', 'female') NOT NULL,
    date_of_birth DATE NOT NULL,
    class_grade VARCHAR(50) NOT NULL,
    admission_date DATE NOT NULL,

    -- What user typed in Parent ID field on student form.
    parent_id_ref VARCHAR(30) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id),
    KEY idx_registrar_students_class_grade (class_grade),
    KEY idx_registrar_students_admission_date (admission_date),
    KEY idx_registrar_students_parent_id_ref (parent_id_ref),
    CONSTRAINT fk_registrar_students_parent
        FOREIGN KEY (parent_id_ref)
        REFERENCES registrar_parents(parent_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS registrar_teachers (
    teacher_code VARCHAR(30) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL,

    -- Store only hashed passwords from backend (bcrypt/argon2), never plain text.
    password_hash VARCHAR(255) NOT NULL,

    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (teacher_code),
    KEY idx_registrar_teachers_full_name (full_name),
    KEY idx_registrar_teachers_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Optional many-to-many links in case one parent has multiple children.
CREATE TABLE IF NOT EXISTS registrar_student_parent_links (
    student_id VARCHAR(30) NOT NULL,
    parent_id VARCHAR(30) NOT NULL,
    is_primary TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id, parent_id),
    KEY idx_registrar_spl_parent (parent_id),
    CONSTRAINT fk_registrar_spl_student
        FOREIGN KEY (student_id)
        REFERENCES registrar_students(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_registrar_spl_parent
        FOREIGN KEY (parent_id)
        REFERENCES registrar_parents(parent_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------
-- Dashboard support tables
-- --------------------------------------------------

CREATE TABLE IF NOT EXISTS registrar_document_requests (
    request_code VARCHAR(30) NOT NULL,
    request_type ENUM('transfer_letter', 'result_transcript', 'official_stamp', 'other') NOT NULL,
    requester_name VARCHAR(150) NOT NULL,
    student_reference VARCHAR(150),
    request_status ENUM('pending', 'ready', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
    requested_on DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_on DATE NULL,
    notes TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (request_code),
    KEY idx_registrar_doc_requests_status_date (request_status, requested_on),
    KEY idx_registrar_doc_requests_type (request_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------
-- Validation triggers
-- --------------------------------------------------

DROP TRIGGER IF EXISTS trg_registrar_students_validate_before_insert;
DROP TRIGGER IF EXISTS trg_registrar_students_validate_before_update;

DELIMITER $$

CREATE TRIGGER trg_registrar_students_validate_before_insert
BEFORE INSERT ON registrar_students
FOR EACH ROW
BEGIN
    DECLARE v_age_years INT;

    SET v_age_years = TIMESTAMPDIFF(YEAR, NEW.date_of_birth, CURDATE());
    IF v_age_years < 2 OR v_age_years > 23 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student age must be between 2 and 23 years.';
    END IF;
END$$

CREATE TRIGGER trg_registrar_students_validate_before_update
BEFORE UPDATE ON registrar_students
FOR EACH ROW
BEGIN
    DECLARE v_age_years INT;

    SET v_age_years = TIMESTAMPDIFF(YEAR, NEW.date_of_birth, CURDATE());
    IF v_age_years < 2 OR v_age_years > 23 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student age must be between 2 and 23 years.';
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------
-- Dashboard helper views
-- --------------------------------------------------

-- Admissions in current quarter (proxy for term).
CREATE OR REPLACE VIEW vw_registrar_admissions_this_term AS
SELECT
    COUNT(*) AS admissions_count,
    SUM(CASE WHEN admission_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN 1 ELSE 0 END) AS pending_review_count
FROM registrar_students
WHERE YEAR(admission_date) = YEAR(CURDATE())
  AND QUARTER(admission_date) = QUARTER(CURDATE());

-- Records updated this quarter.
CREATE OR REPLACE VIEW vw_registrar_records_updated_this_term AS
SELECT COUNT(*) AS records_updated_count
FROM registrar_students
WHERE YEAR(updated_at) = YEAR(CURDATE())
  AND QUARTER(updated_at) = QUARTER(CURDATE());

-- Document requests status summary for queue card.
CREATE OR REPLACE VIEW vw_registrar_document_requests_summary AS
SELECT
    COUNT(*) AS total_requests,
    SUM(CASE WHEN request_status = 'ready' THEN 1 ELSE 0 END) AS ready_for_pickup,
    SUM(CASE WHEN request_status = 'pending' THEN 1 ELSE 0 END) AS pending_requests
FROM registrar_document_requests
WHERE YEAR(requested_on) = YEAR(CURDATE())
  AND QUARTER(requested_on) = QUARTER(CURDATE());

-- --------------------------------------------------
-- Suggested write pattern
-- --------------------------------------------------
-- 1) Create parent first (from parent form)
-- INSERT INTO registrar_parents (parent_id, full_name, relationship_to_student, phone)
-- VALUES ('PAR-20260323-1001', 'Mary K.', 'Mother', '+243000000000');
--
-- 2) Insert student from student form
-- INSERT INTO registrar_students (
--     student_id, first_name, last_name, gender, date_of_birth,
--     class_grade, admission_date, parent_id_ref
-- )
-- VALUES (
--     'STU-20260323-4821', 'John', 'Doe', 'male', '2012-03-23',
--     'Grade 7', '2026-03-23', 'PAR-20260323-1001'
-- );
--
-- 3) Insert teacher (password_hash produced by backend)
-- INSERT INTO registrar_teachers (teacher_code, full_name, phone, password_hash)
-- VALUES ('TCH-20260323-0001', 'Alice N.', '+243000000001', '$2b$12$example_hash_here');