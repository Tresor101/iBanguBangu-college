-- MySQL (Hostinger/phpMyAdmin) schema for deputy_principal module
-- Covers: dashboard.html and registration.html
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS deputy_principal_support_staff (
    staff_id BIGINT NOT NULL AUTO_INCREMENT,
    role ENUM('Secretary', 'Finance', 'Disciplinary Officer') NOT NULL,
    full_name VARCHAR(80) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (staff_id),
    UNIQUE KEY uq_deputy_staff_phone (phone),
    KEY idx_deputy_staff_role_active (role, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS deputy_principal_operational_tasks (
    task_id BIGINT NOT NULL AUTO_INCREMENT,
    area VARCHAR(120) NOT NULL,
    owner_name VARCHAR(120) NOT NULL,
    progress_percent TINYINT UNSIGNED NOT NULL DEFAULT 0,
    due_date DATE NULL,
    status ENUM('pending', 'in_progress', 'completed', 'blocked') NOT NULL DEFAULT 'pending',
    notes TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (task_id),
    KEY idx_deputy_tasks_status_due (status, due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS deputy_principal_incidents (
    incident_id BIGINT NOT NULL AUTO_INCREMENT,
    incident_title VARCHAR(150) NOT NULL,
    incident_details TEXT NULL,
    severity ENUM('low', 'medium', 'high', 'critical') NOT NULL DEFAULT 'medium',
    status ENUM('open', 'under_review', 'resolved', 'closed') NOT NULL DEFAULT 'open',
    requires_parent_meeting TINYINT(1) NOT NULL DEFAULT 0,
    reported_on DATE NOT NULL,
    resolved_on DATE NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (incident_id),
    KEY idx_deputy_incidents_status_date (status, reported_on),
    KEY idx_deputy_incidents_parent_meeting (requires_parent_meeting)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS deputy_principal_supervision_checklist (
    checklist_id BIGINT NOT NULL AUTO_INCREMENT,
    task_name VARCHAR(150) NOT NULL,
    status ENUM('pending', 'in_progress', 'completed', 'scheduled') NOT NULL DEFAULT 'pending',
    scheduled_date DATE NULL,
    completed_at DATETIME NULL,
    reviewed_by VARCHAR(120) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (checklist_id),
    KEY idx_deputy_checklist_status_date (status, scheduled_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS deputy_principal_daily_attendance (
    attendance_id BIGINT NOT NULL AUTO_INCREMENT,
    attendance_date DATE NOT NULL,
    student_attendance_rate DECIMAL(5,2) NOT NULL,
    staff_attendance_rate DECIMAL(5,2) NOT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (attendance_id),
    UNIQUE KEY uq_deputy_attendance_date (attendance_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP VIEW IF EXISTS vw_deputy_dashboard_summary;
CREATE VIEW vw_deputy_dashboard_summary AS
SELECT
    (SELECT COUNT(*)
     FROM deputy_principal_operational_tasks t
     WHERE t.status IN ('pending', 'in_progress', 'blocked')) AS open_operational_tasks,
    (SELECT COUNT(*)
     FROM deputy_principal_operational_tasks t
     WHERE t.status IN ('pending', 'in_progress', 'blocked')
       AND t.due_date = CURDATE()) AS tasks_due_today,
    (SELECT COUNT(*)
     FROM deputy_principal_incidents i
     WHERE i.status IN ('open', 'under_review')) AS incidents_pending,
    (SELECT COUNT(*)
     FROM deputy_principal_incidents i
     WHERE i.status IN ('open', 'under_review')
       AND i.requires_parent_meeting = 1) AS parent_meetings_required,
    (SELECT COALESCE(a.student_attendance_rate, 0)
     FROM deputy_principal_daily_attendance a
     ORDER BY a.attendance_date DESC
     LIMIT 1) AS latest_student_attendance_rate,
    (SELECT COALESCE(a.staff_attendance_rate, 0)
     FROM deputy_principal_daily_attendance a
     ORDER BY a.attendance_date DESC
     LIMIT 1) AS latest_staff_attendance_rate;

-- Optional sample records for quick dashboard testing
INSERT INTO deputy_principal_operational_tasks (area, owner_name, progress_percent, due_date, status)
VALUES
('Exam room setup', 'Admin Office', 80, CURDATE(), 'in_progress'),
('Transport schedule', 'Operations', 100, CURDATE(), 'completed'),
('Facility maintenance', 'Caretaker', 65, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'in_progress')
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

INSERT INTO deputy_principal_incidents (incident_title, incident_details, severity, status, requires_parent_meeting, reported_on)
VALUES
('Late teacher arrivals', 'Three repeated cases this week.', 'medium', 'under_review', 0, CURDATE()),
('Bus route complaint', 'Parent feedback under review.', 'low', 'open', 1, CURDATE())
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

INSERT INTO deputy_principal_supervision_checklist (task_name, status, scheduled_date)
VALUES
('Morning assembly', 'completed', CURDATE()),
('Classroom rounds', 'in_progress', CURDATE()),
('Teacher register audit', 'pending', CURDATE()),
('Facilities inspection', 'scheduled', DATE_ADD(CURDATE(), INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

INSERT INTO deputy_principal_daily_attendance (attendance_date, student_attendance_rate, staff_attendance_rate)
VALUES (CURDATE(), 94.00, 97.00)
ON DUPLICATE KEY UPDATE
    student_attendance_rate = VALUES(student_attendance_rate),
    staff_attendance_rate = VALUES(staff_attendance_rate);
