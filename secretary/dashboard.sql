-- MySQL (Hostinger/phpMyAdmin) schema + dashboard views for dashboard.html
SET NAMES utf8mb4;

-- Core tables referenced by the dashboard.
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
    PRIMARY KEY (parent_code)
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
    KEY idx_secretary_students_parent_code (parent_code),
    CONSTRAINT fk_secretary_students_parent_for_dashboard
        FOREIGN KEY (parent_code)
        REFERENCES secretary_parents(parent_code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS secretary_document_requests (
    request_code VARCHAR(30) NOT NULL,
    request_type ENUM('transfer_letter', 'result_transcript', 'official_stamp', 'meeting_notice', 'other') NOT NULL,
    requester_name VARCHAR(150) NOT NULL,
    student_reference VARCHAR(150) NULL,
    request_status ENUM('pending', 'ready', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
    requested_on DATE NOT NULL,
    due_on DATE NULL,
    notes TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (request_code),
    KEY idx_secretary_doc_requests_status_date (request_status, requested_on)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dashboard helper views
DROP VIEW IF EXISTS vw_secretary_admissions_this_term;
CREATE VIEW vw_secretary_admissions_this_term AS
SELECT
    COUNT(*) AS admissions_count,
    SUM(CASE WHEN admission_date >= DATE_SUB(CURDATE(), INTERVAL 14 DAY) THEN 1 ELSE 0 END) AS pending_review_count
FROM secretary_students
WHERE YEAR(admission_date) = YEAR(CURDATE())
  AND QUARTER(admission_date) = QUARTER(CURDATE());

DROP VIEW IF EXISTS vw_secretary_records_updated_this_term;
CREATE VIEW vw_secretary_records_updated_this_term AS
SELECT COUNT(*) AS records_updated_count
FROM secretary_students
WHERE YEAR(updated_at) = YEAR(CURDATE())
  AND QUARTER(updated_at) = QUARTER(CURDATE());

DROP VIEW IF EXISTS vw_secretary_document_requests_summary;
CREATE VIEW vw_secretary_document_requests_summary AS
SELECT
    COUNT(*) AS total_requests,
    SUM(CASE WHEN request_status = 'ready' THEN 1 ELSE 0 END) AS ready_for_pickup,
    SUM(CASE WHEN request_status = 'pending' THEN 1 ELSE 0 END) AS pending_requests
FROM secretary_document_requests
WHERE YEAR(requested_on) = YEAR(CURDATE())
  AND QUARTER(requested_on) = QUARTER(CURDATE());
