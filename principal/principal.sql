-- MySQL (Hostinger/phpMyAdmin) schema for principal module
-- Covers: dashboard.html and registration.html
SET NAMES utf8mb4;

-- ─────────────────────────────────────────────
-- dashboard.html
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS principal_subject_performance (
    performance_id BIGINT NOT NULL AUTO_INCREMENT,
    subject_name VARCHAR(100) NOT NULL,
    teacher_name VARCHAR(120) NOT NULL,
    average_percent DECIMAL(5,2) NOT NULL,
    coverage_percent DECIMAL(5,2) NOT NULL,
    term_label VARCHAR(60) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (performance_id),
    KEY idx_principal_subject_term (subject_name, term_label)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS principal_exam_control (
    exam_control_id BIGINT NOT NULL AUTO_INCREMENT,
    term_label VARCHAR(60) NOT NULL,
    papers_submitted INT NOT NULL DEFAULT 0,
    papers_moderated INT NOT NULL DEFAULT 0,
    invigilators_assigned INT NOT NULL DEFAULT 0,
    printing_status ENUM('pending', 'in_progress', 'completed') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (exam_control_id),
    UNIQUE KEY uq_principal_exam_control_term (term_label)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS principal_academic_actions (
    action_id BIGINT NOT NULL AUTO_INCREMENT,
    action_title VARCHAR(180) NOT NULL,
    action_notes TEXT NULL,
    status ENUM('pending', 'in_progress', 'done') NOT NULL DEFAULT 'pending',
    priority ENUM('low', 'medium', 'high') NOT NULL DEFAULT 'medium',
    due_date DATE NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (action_id),
    KEY idx_principal_actions_status_priority (status, priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS principal_dashboard_metrics (
    metric_id BIGINT NOT NULL AUTO_INCREMENT,
    term_label VARCHAR(60) NOT NULL,
    pass_rate_percent DECIMAL(5,2) NOT NULL,
    exam_readiness_percent DECIMAL(5,2) NOT NULL,
    lesson_coverage_percent DECIMAL(5,2) NOT NULL,
    papers_approved INT NOT NULL DEFAULT 0,
    papers_total INT NOT NULL DEFAULT 0,
    target_pass_rate_percent DECIMAL(5,2) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (metric_id),
    UNIQUE KEY uq_principal_metrics_term (term_label)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP VIEW IF EXISTS vw_principal_dashboard_snapshot;
CREATE VIEW vw_principal_dashboard_snapshot AS
SELECT
    m.term_label,
    m.pass_rate_percent,
    m.exam_readiness_percent,
    m.lesson_coverage_percent,
    m.papers_approved,
    m.papers_total,
    e.papers_submitted,
    e.papers_moderated,
    e.invigilators_assigned,
    e.printing_status
FROM principal_dashboard_metrics m
LEFT JOIN principal_exam_control e ON e.term_label = m.term_label;

-- ─────────────────────────────────────────────
-- registration.html
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS principal_deputy_academic_directors (
    deputy_id BIGINT NOT NULL AUTO_INCREMENT,
    role VARCHAR(80) NOT NULL DEFAULT 'Deputy Academic Director',
    full_name VARCHAR(80) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (deputy_id),
    UNIQUE KEY uq_principal_deputy_phone (phone),
    KEY idx_principal_deputy_role_active (role, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS principal_registration_audit (
    audit_id BIGINT NOT NULL AUTO_INCREMENT,
    deputy_id BIGINT NOT NULL,
    action_type ENUM('created', 'updated', 'deactivated') NOT NULL DEFAULT 'created',
    action_note VARCHAR(255) NULL,
    action_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (audit_id),
    KEY idx_principal_registration_audit_deputy (deputy_id),
    CONSTRAINT fk_principal_registration_audit_deputy
        FOREIGN KEY (deputy_id)
        REFERENCES principal_deputy_academic_directors(deputy_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────
-- Seed data
-- ─────────────────────────────────────────────

INSERT INTO principal_dashboard_metrics
(term_label, pass_rate_percent, exam_readiness_percent, lesson_coverage_percent, papers_approved, papers_total, target_pass_rate_percent)
VALUES
('Term 1', 87.00, 78.00, 82.00, 39, 50, 90.00)
ON DUPLICATE KEY UPDATE
    pass_rate_percent = VALUES(pass_rate_percent),
    exam_readiness_percent = VALUES(exam_readiness_percent),
    lesson_coverage_percent = VALUES(lesson_coverage_percent),
    papers_approved = VALUES(papers_approved),
    papers_total = VALUES(papers_total),
    target_pass_rate_percent = VALUES(target_pass_rate_percent);

INSERT INTO principal_exam_control
(term_label, papers_submitted, papers_moderated, invigilators_assigned, printing_status)
VALUES
('Term 1', 39, 31, 22, 'pending')
ON DUPLICATE KEY UPDATE
    papers_submitted = VALUES(papers_submitted),
    papers_moderated = VALUES(papers_moderated),
    invigilators_assigned = VALUES(invigilators_assigned),
    printing_status = VALUES(printing_status);
