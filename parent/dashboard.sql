-- MySQL (Hostinger/phpMyAdmin) schema for parent/dashboard.html
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS parent_accounts (
    parent_id VARCHAR(30) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(150) NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (parent_id),
    UNIQUE KEY uq_parent_accounts_phone (phone),
    UNIQUE KEY uq_parent_accounts_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS parent_students (
    student_id VARCHAR(30) NOT NULL,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    grade_label VARCHAR(60) NOT NULL,
    school_level ENUM('primary', 'high') NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id),
    KEY idx_parent_students_grade (grade_label),
    KEY idx_parent_students_level (school_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS parent_student_links (
    link_id BIGINT NOT NULL AUTO_INCREMENT,
    parent_id VARCHAR(30) NOT NULL,
    student_id VARCHAR(30) NOT NULL,
    relationship_type VARCHAR(40) NOT NULL DEFAULT 'Guardian',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (link_id),
    UNIQUE KEY uq_parent_student_unique (parent_id, student_id),
    KEY idx_parent_student_parent (parent_id),
    KEY idx_parent_student_student (student_id),
    CONSTRAINT fk_parent_student_links_parent
        FOREIGN KEY (parent_id)
        REFERENCES parent_accounts(parent_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_parent_student_links_student
        FOREIGN KEY (student_id)
        REFERENCES parent_students(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS parent_attendance_summary (
    attendance_id BIGINT NOT NULL AUTO_INCREMENT,
    student_id VARCHAR(30) NOT NULL,
    period_label VARCHAR(80) NOT NULL,
    total_days INT NOT NULL,
    present_days INT NOT NULL,
    attendance_percent DECIMAL(5,2) NOT NULL,
    recorded_on DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (attendance_id),
    KEY idx_parent_attendance_student_date (student_id, recorded_on),
    CONSTRAINT fk_parent_attendance_student
        FOREIGN KEY (student_id)
        REFERENCES parent_students(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS parent_fee_balances (
    fee_id BIGINT NOT NULL AUTO_INCREMENT,
    student_id VARCHAR(30) NOT NULL,
    term_label VARCHAR(60) NOT NULL,
    balance_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    due_date DATE NULL,
    status ENUM('no_balance', 'pending', 'overdue', 'paid') NOT NULL DEFAULT 'pending',
    updated_on DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (fee_id),
    KEY idx_parent_fee_student_term (student_id, term_label),
    CONSTRAINT fk_parent_fee_student
        FOREIGN KEY (student_id)
        REFERENCES parent_students(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS parent_result_headers (
    result_id BIGINT NOT NULL AUTO_INCREMENT,
    student_id VARCHAR(30) NOT NULL,
    result_type ENUM('term', 'semester') NOT NULL,
    term_number TINYINT NOT NULL,
    semester_number TINYINT NULL,
    result_label VARCHAR(80) NOT NULL,
    published_on DATE NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (result_id),
    UNIQUE KEY uq_parent_results_unique (student_id, result_type, term_number, semester_number),
    KEY idx_parent_results_student (student_id),
    CONSTRAINT fk_parent_results_student
        FOREIGN KEY (student_id)
        REFERENCES parent_students(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS parent_result_items (
    result_item_id BIGINT NOT NULL AUTO_INCREMENT,
    result_id BIGINT NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    grade VARCHAR(5) NOT NULL,
    remark VARCHAR(40) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (result_item_id),
    UNIQUE KEY uq_parent_result_subject (result_id, subject_name),
    KEY idx_parent_result_items_result (result_id),
    CONSTRAINT fk_parent_result_items_header
        FOREIGN KEY (result_id)
        REFERENCES parent_result_headers(result_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS parent_announcements (
    announcement_id BIGINT NOT NULL AUTO_INCREMENT,
    title VARCHAR(180) NOT NULL,
    body_text TEXT NOT NULL,
    target_level ENUM('all', 'primary', 'high') NOT NULL DEFAULT 'all',
    publish_date DATE NOT NULL,
    expiry_date DATE NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (announcement_id),
    KEY idx_parent_announcements_dates (publish_date, expiry_date),
    KEY idx_parent_announcements_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP VIEW IF EXISTS vw_parent_dashboard_student_snapshot;
CREATE VIEW vw_parent_dashboard_student_snapshot AS
SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS full_name,
    s.grade_label,
    s.school_level,
    COALESCE(a.attendance_percent, 0.00) AS latest_attendance_percent,
    COALESCE(a.present_days, 0) AS latest_present_days,
    COALESCE(a.total_days, 0) AS latest_total_days,
    COALESCE(f.balance_amount, 0.00) AS latest_balance_amount,
    f.due_date AS latest_fee_due_date
FROM parent_students s
LEFT JOIN (
    SELECT x.student_id, x.attendance_percent, x.present_days, x.total_days
    FROM parent_attendance_summary x
    INNER JOIN (
        SELECT student_id, MAX(recorded_on) AS max_date
        FROM parent_attendance_summary
        GROUP BY student_id
    ) latest ON latest.student_id = x.student_id AND latest.max_date = x.recorded_on
) a ON a.student_id = s.student_id
LEFT JOIN (
    SELECT y.student_id, y.balance_amount, y.due_date
    FROM parent_fee_balances y
    INNER JOIN (
        SELECT student_id, MAX(updated_on) AS max_date
        FROM parent_fee_balances
        GROUP BY student_id
    ) latest_fee ON latest_fee.student_id = y.student_id AND latest_fee.max_date = y.updated_on
) f ON f.student_id = s.student_id;

-- Optional seed data for quick demo
INSERT INTO parent_accounts (parent_id, full_name, phone, email)
VALUES ('PAR260001', 'Jane Doe', '+250700000001', 'jane.doe@example.com')
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

INSERT INTO parent_students (student_id, first_name, last_name, grade_label, school_level)
VALUES ('STU-20260304-1234', 'John', 'Doe', 'Grade 10 - A', 'high')
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

INSERT INTO parent_student_links (parent_id, student_id, relationship_type)
VALUES ('PAR260001', 'STU-20260304-1234', 'Mother')
ON DUPLICATE KEY UPDATE relationship_type = VALUES(relationship_type);

INSERT INTO parent_attendance_summary (student_id, period_label, total_days, present_days, attendance_percent, recorded_on)
VALUES ('STU-20260304-1234', 'Term 1', 50, 47, 94.00, CURDATE())
ON DUPLICATE KEY UPDATE attendance_percent = VALUES(attendance_percent), present_days = VALUES(present_days), total_days = VALUES(total_days);

INSERT INTO parent_fee_balances (student_id, term_label, balance_amount, due_date, status, updated_on)
VALUES ('STU-20260304-1234', 'Term 1', 120.00, DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'pending', CURDATE())
ON DUPLICATE KEY UPDATE balance_amount = VALUES(balance_amount), due_date = VALUES(due_date), status = VALUES(status);

INSERT INTO parent_result_headers (student_id, result_type, term_number, semester_number, result_label, published_on)
VALUES ('STU-20260304-1234', 'term', 1, NULL, 'Term 1 Assessment', CURDATE())
ON DUPLICATE KEY UPDATE published_on = VALUES(published_on);

INSERT INTO parent_announcements (title, body_text, target_level, publish_date, expiry_date, is_active)
VALUES ('Parent-Teacher Meeting', 'Friday, Mar 15 at 10:00 AM', 'all', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 1)
ON DUPLICATE KEY UPDATE body_text = VALUES(body_text), expiry_date = VALUES(expiry_date), is_active = VALUES(is_active);
