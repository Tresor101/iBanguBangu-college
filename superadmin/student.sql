-- MySQL (Hostinger/phpMyAdmin) schema for student module
-- Covers: student/dashboard.html
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS student_accounts (
    student_id VARCHAR(30) NOT NULL,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    class_grade VARCHAR(60) NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id),
    KEY idx_student_accounts_grade (class_grade),
    KEY idx_student_accounts_year (academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_attendance (
    attendance_id BIGINT NOT NULL AUTO_INCREMENT,
    student_id VARCHAR(30) NOT NULL,
    term_label VARCHAR(60) NOT NULL,
    total_days INT NOT NULL,
    present_days INT NOT NULL,
    attendance_percent DECIMAL(5,2) NOT NULL,
    recorded_on DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (attendance_id),
    UNIQUE KEY uq_student_attendance_term (student_id, term_label),
    KEY idx_student_attendance_date (recorded_on),
    CONSTRAINT fk_student_attendance_account
        FOREIGN KEY (student_id)
        REFERENCES student_accounts(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_fee_payments (
    fee_id BIGINT NOT NULL AUTO_INCREMENT,
    student_id VARCHAR(30) NOT NULL,
    term_label VARCHAR(60) NOT NULL,
    payments_made INT NOT NULL DEFAULT 0,
    remaining_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    next_due_date DATE NULL,
    status ENUM('no_balance', 'pending', 'overdue', 'paid') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (fee_id),
    UNIQUE KEY uq_student_fee_term (student_id, term_label),
    CONSTRAINT fk_student_fee_account
        FOREIGN KEY (student_id)
        REFERENCES student_accounts(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_results (
    result_id BIGINT NOT NULL AUTO_INCREMENT,
    student_id VARCHAR(30) NOT NULL,
    term_label VARCHAR(60) NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    grade VARCHAR(5) NOT NULL,
    remark VARCHAR(40) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (result_id),
    UNIQUE KEY uq_student_results_subject_term (student_id, term_label, subject_name),
    KEY idx_student_results_term (student_id, term_label),
    CONSTRAINT fk_student_results_account
        FOREIGN KEY (student_id)
        REFERENCES student_accounts(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_schedule (
    schedule_id BIGINT NOT NULL AUTO_INCREMENT,
    student_id VARCHAR(30) NOT NULL,
    day_of_week ENUM('Monday','Tuesday','Wednesday','Thursday','Friday') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (schedule_id),
    KEY idx_student_schedule_student_day (student_id, day_of_week),
    CONSTRAINT fk_student_schedule_account
        FOREIGN KEY (student_id)
        REFERENCES student_accounts(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_announcements (
    announcement_id BIGINT NOT NULL AUTO_INCREMENT,
    title VARCHAR(180) NOT NULL,
    body_text TEXT NOT NULL,
    target_grade VARCHAR(60) NULL,
    publish_date DATE NOT NULL,
    expiry_date DATE NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (announcement_id),
    KEY idx_student_announcements_active_date (is_active, publish_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP VIEW IF EXISTS vw_student_dashboard_snapshot;
CREATE VIEW vw_student_dashboard_snapshot AS
SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS full_name,
    s.class_grade,
    s.academic_year,
    COALESCE(a.attendance_percent, 0.00) AS attendance_percent,
    COALESCE(a.present_days, 0) AS present_days,
    COALESCE(a.total_days, 0) AS total_days,
    COALESCE(f.payments_made, 0) AS fee_payments_made,
    COALESCE(f.remaining_amount, 0.00) AS fee_remaining_amount,
    f.next_due_date AS fee_next_due_date,
    ROUND(COALESCE(
        (SELECT AVG(r.score) FROM student_results r
         WHERE r.student_id = s.student_id
           AND r.term_label = (
               SELECT term_label FROM student_results
               WHERE student_id = s.student_id
               ORDER BY created_at DESC LIMIT 1
           )),
    0), 2) AS current_average_percent
FROM student_accounts s
LEFT JOIN (
    SELECT x.student_id, x.attendance_percent, x.present_days, x.total_days
    FROM student_attendance x
    INNER JOIN (
        SELECT student_id, MAX(recorded_on) AS max_date
        FROM student_attendance
        GROUP BY student_id
    ) latest ON latest.student_id = x.student_id AND latest.max_date = x.recorded_on
) a ON a.student_id = s.student_id
LEFT JOIN (
    SELECT y.student_id, y.payments_made, y.remaining_amount, y.next_due_date
    FROM student_fee_payments y
    INNER JOIN (
        SELECT student_id, MAX(updated_at) AS max_date
        FROM student_fee_payments
        GROUP BY student_id
    ) latest_fee ON latest_fee.student_id = y.student_id AND latest_fee.max_date = y.updated_at
) f ON f.student_id = s.student_id;

-- Seed data
INSERT INTO student_accounts (student_id, first_name, last_name, class_grade, academic_year)
VALUES ('STU-20260304-1234', 'John', 'Doe', 'Grade 10 - A', '2025-2026')
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

INSERT INTO student_attendance (student_id, term_label, total_days, present_days, attendance_percent, recorded_on)
VALUES ('STU-20260304-1234', 'Term 2', 50, 47, 94.00, CURDATE())
ON DUPLICATE KEY UPDATE present_days = VALUES(present_days), attendance_percent = VALUES(attendance_percent);

INSERT INTO student_fee_payments (student_id, term_label, payments_made, remaining_amount, next_due_date, status)
VALUES ('STU-20260304-1234', 'Term 2', 3, 120.00, DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'pending')
ON DUPLICATE KEY UPDATE payments_made = VALUES(payments_made), remaining_amount = VALUES(remaining_amount);

INSERT INTO student_results (student_id, term_label, subject_name, score, grade, remark)
VALUES
('STU-20260304-1234', 'Term 2', 'Mathematics', 89.00, 'A',  'Excellent'),
('STU-20260304-1234', 'Term 2', 'Science',     84.00, 'B+', 'Very Good'),
('STU-20260304-1234', 'Term 2', 'English',     80.00, 'B',  'Good'),
('STU-20260304-1234', 'Term 2', 'History',     91.00, 'A',  'Excellent')
ON DUPLICATE KEY UPDATE score = VALUES(score), grade = VALUES(grade), remark = VALUES(remark);

INSERT INTO student_schedule (student_id, day_of_week, start_time, end_time, subject_name)
VALUES
('STU-20260304-1234', 'Monday', '08:00:00', '09:00:00', 'Mathematics'),
('STU-20260304-1234', 'Monday', '09:15:00', '10:15:00', 'English'),
('STU-20260304-1234', 'Monday', '10:30:00', '11:30:00', 'Science'),
('STU-20260304-1234', 'Monday', '13:00:00', '14:00:00', 'History')
ON DUPLICATE KEY UPDATE subject_name = VALUES(subject_name);

INSERT INTO student_announcements (title, body_text, target_grade, publish_date, expiry_date, is_active)
VALUES
('Midterm Exam Starts Next Week', 'Please review the updated schedule and prepare required materials.', NULL, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 1),
('Science Project Submission', 'Deadline: Mar 10 before 4:00 PM.', 'Grade 10 - A', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 1),
('Sports Day Practice', 'Practice sessions start this Friday at 3:30 PM.', NULL, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 1)
ON DUPLICATE KEY UPDATE body_text = VALUES(body_text), is_active = VALUES(is_active);
