-- MySQL (Hostinger/phpMyAdmin) schema for message.html
SET NAMES utf8mb4;

-- Dependency table (already created by class-grade.sql, kept here for safe standalone import).
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

CREATE TABLE IF NOT EXISTS secretary_broadcast_messages (
    broadcast_id BIGINT NOT NULL AUTO_INCREMENT,
    audience_type ENUM('all_students', 'all_parents', 'all_teachers', 'department_heads', 'classes_grade') NOT NULL,
    class_code VARCHAR(30) NULL,
    class_grade_label VARCHAR(120) NULL,
    message_body TEXT NOT NULL,
    sent_by VARCHAR(120) NULL,
    posted_on_dashboard TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (broadcast_id),
    KEY idx_secretary_broadcast_audience (audience_type),
    KEY idx_secretary_broadcast_created_at (created_at),
    KEY idx_secretary_broadcast_class_code (class_code),
    CONSTRAINT fk_secretary_broadcast_class
        FOREIGN KEY (class_code)
        REFERENCES secretary_classes(class_code)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dashboard feed view (newest first)
DROP VIEW IF EXISTS vw_secretary_dashboard_broadcast_feed;
CREATE VIEW vw_secretary_dashboard_broadcast_feed AS
SELECT
    bm.broadcast_id,
    bm.audience_type,
    bm.class_code,
    bm.class_grade_label,
    bm.message_body,
    bm.sent_by,
    bm.created_at
FROM secretary_broadcast_messages AS bm
WHERE bm.posted_on_dashboard = 1
ORDER BY bm.created_at DESC;

-- Optional sample data
INSERT INTO secretary_broadcast_messages (audience_type, class_grade_label, message_body, sent_by)
VALUES
('all_students', NULL, 'Assembly starts at 8:00 AM tomorrow.', 'Secretary Office'),
('classes_grade', 'Grade 8 - A', 'Grade 8A report cards are ready for collection.', 'Secretary Office');
