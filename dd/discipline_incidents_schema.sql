-- Hostinger-compatible schema (MySQL 8 / MariaDB) aligned with:
-- - dd/discipline-officer-dashboard.html
-- Features:
-- - Record student discipline incidents from the dashboard form
-- - Search incident history by student, date, type, and status
-- - Track parent meetings and follow-up actions
-- - Provide summary views for dashboard stat cards and hotspot classes
--
-- Depends on tables from student_registration_schema.sql:
-- - students
-- - classes
-- - class_student_enrollments
-- - management_staff

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS discipline_incidents (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    -- Optional links to existing master records.
    student_db_id BIGINT UNSIGNED NULL,
    reported_by_staff_id BIGINT UNSIGNED NULL,
    assigned_to_staff_id BIGINT UNSIGNED NULL,

    -- Keep free-text copies because the dashboard currently accepts manual entry.
    student_reference VARCHAR(150) NOT NULL,
    incident_type ENUM(
        'Fighting',
        'Late Arrival',
        'Uniform Violation',
        'Class Disruption',
        'Absenteeism',
        'Insubordination',
        'Other'
    ) NOT NULL,
    severity ENUM('low', 'medium', 'high', 'critical') NOT NULL DEFAULT 'medium',
    description TEXT NOT NULL,
    action_taken ENUM(
        'Warning',
        'Parent Called',
        'Counselling',
        'Suspension',
        'Monitoring',
        'Other'
    ) NOT NULL,
    incident_status ENUM('Open', 'Monitoring', 'Resolved') NOT NULL DEFAULT 'Open',
    occurred_on DATE NOT NULL,
    occurred_at TIME NULL,
    location_name VARCHAR(120) NULL,
    requires_parent_meeting TINYINT(1) NOT NULL DEFAULT 0,
    follow_up_due_date DATE NULL,
    resolution_notes TEXT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_discipline_incidents_date_status (occurred_on, incident_status),
    KEY idx_discipline_incidents_type_date (incident_type, occurred_on),
    KEY idx_discipline_incidents_student_ref (student_reference),
    KEY idx_discipline_incidents_student_db (student_db_id),
    KEY idx_discipline_incidents_assigned_staff (assigned_to_staff_id),

    CONSTRAINT fk_discipline_incidents_student
        FOREIGN KEY (student_db_id)
        REFERENCES students(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_discipline_incidents_reporter
        FOREIGN KEY (reported_by_staff_id)
        REFERENCES management_staff(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_discipline_incidents_assignee
        FOREIGN KEY (assigned_to_staff_id)
        REFERENCES management_staff(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_discipline_follow_up_due
        CHECK (follow_up_due_date IS NULL OR follow_up_due_date >= occurred_on)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS discipline_parent_meetings (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    incident_id BIGINT UNSIGNED NOT NULL,
    meeting_date DATE NOT NULL,
    meeting_time TIME NULL,
    meeting_status ENUM('Scheduled', 'Completed', 'Cancelled', 'No Show') NOT NULL DEFAULT 'Scheduled',
    notes TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_discipline_parent_meetings_date_status (meeting_date, meeting_status),
    CONSTRAINT fk_discipline_parent_meetings_incident
        FOREIGN KEY (incident_id)
        REFERENCES discipline_incidents(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS discipline_follow_up_actions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    incident_id BIGINT UNSIGNED NOT NULL,
    action_note VARCHAR(255) NOT NULL,
    action_status ENUM('pending', 'completed') NOT NULL DEFAULT 'pending',
    due_date DATE NULL,
    completed_at DATETIME NULL,
    created_by_staff_id BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_discipline_follow_up_status_due (action_status, due_date),
    CONSTRAINT fk_discipline_follow_up_incident
        FOREIGN KEY (incident_id)
        REFERENCES discipline_incidents(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_discipline_follow_up_creator
        FOREIGN KEY (created_by_staff_id)
        REFERENCES management_staff(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_discipline_follow_up_completed
        CHECK (completed_at IS NULL OR action_status = 'completed')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------
-- Dashboard helper views
-- --------------------------------------------------

-- Incidents this calendar week, with serious-case count.
CREATE OR REPLACE VIEW vw_discipline_incidents_this_week AS
SELECT
    COUNT(*) AS incidents_this_week,
    SUM(CASE WHEN severity IN ('high', 'critical') THEN 1 ELSE 0 END) AS serious_cases
FROM discipline_incidents
WHERE YEARWEEK(occurred_on, 1) = YEARWEEK(CURDATE(), 1);

-- Late arrivals this week and repeat offenders.
CREATE OR REPLACE VIEW vw_discipline_late_arrivals_this_week AS
SELECT
    COUNT(*) AS late_arrivals_this_week,
    COUNT(DISTINCT repeaters.student_key) AS repeat_offenders
FROM discipline_incidents incident
LEFT JOIN (
    SELECT
        COALESCE(CAST(student_db_id AS CHAR), student_reference) AS student_key
    FROM discipline_incidents
    WHERE incident_type = 'Late Arrival'
      AND YEARWEEK(occurred_on, 1) = YEARWEEK(CURDATE(), 1)
    GROUP BY COALESCE(CAST(student_db_id AS CHAR), student_reference)
    HAVING COUNT(*) > 1
) repeaters
    ON repeaters.student_key = COALESCE(CAST(incident.student_db_id AS CHAR), incident.student_reference)
WHERE incident.incident_type = 'Late Arrival'
  AND YEARWEEK(incident.occurred_on, 1) = YEARWEEK(CURDATE(), 1);

-- Parent meetings this week and pending follow-up count.
CREATE OR REPLACE VIEW vw_discipline_parent_meetings_this_week AS
SELECT
    COUNT(*) AS meetings_this_week,
    SUM(CASE WHEN meeting_status = 'Scheduled' THEN 1 ELSE 0 END) AS pending_follow_up
FROM discipline_parent_meetings
WHERE YEARWEEK(meeting_date, 1) = YEARWEEK(CURDATE(), 1);

-- Hotspot classes based on incident counts. Falls back to class_grade on students if enrollment link is absent.
CREATE OR REPLACE VIEW vw_discipline_hotspot_classes AS
SELECT
    COALESCE(classes.class_grade, students.class_grade, 'Unassigned') AS class_grade,
    COALESCE(classes.section, students.section, '-') AS section_name,
    COUNT(*) AS incident_count
FROM discipline_incidents
LEFT JOIN students
    ON students.id = discipline_incidents.student_db_id
LEFT JOIN class_student_enrollments enrollments
    ON enrollments.student_id = students.id
LEFT JOIN classes
    ON classes.id = enrollments.class_id
GROUP BY COALESCE(classes.class_grade, students.class_grade, 'Unassigned'), COALESCE(classes.section, students.section, '-')
ORDER BY incident_count DESC, class_grade ASC, section_name ASC;

-- Search-friendly incident history view for the frontend filters.
CREATE OR REPLACE VIEW vw_discipline_incident_history AS
SELECT
    incident.id,
    incident.student_reference,
    incident.incident_type,
    incident.severity,
    incident.action_taken,
    incident.incident_status,
    incident.occurred_on,
    incident.follow_up_due_date,
    students.class_grade,
    students.section,
    reporter.full_name AS reported_by_name,
    assignee.full_name AS assigned_to_name
FROM discipline_incidents incident
LEFT JOIN students
    ON students.id = incident.student_db_id
LEFT JOIN management_staff reporter
    ON reporter.id = incident.reported_by_staff_id
LEFT JOIN management_staff assignee
    ON assignee.id = incident.assigned_to_staff_id;

-- --------------------------------------------------
-- Suggested write pattern
-- --------------------------------------------------
-- 1) Record an incident from the Update Incident form.
-- INSERT INTO discipline_incidents (
--     student_reference,
--     incident_type,
--     description,
--     action_taken,
--     incident_status,
--     occurred_on
-- ) VALUES (
--     'John K. / STU-20260323-0001',
--     'Fighting',
--     'Fight reported during morning break near the assembly area.',
--     'Parent Called',
--     'Open',
--     CURDATE()
-- );
--
-- 2) Optional: schedule a parent meeting for the incident.
-- INSERT INTO discipline_parent_meetings (incident_id, meeting_date, meeting_status)
-- VALUES (LAST_INSERT_ID(), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 'Scheduled');
--
-- 3) Search history from the dashboard filters.
-- SELECT *
-- FROM vw_discipline_incident_history
-- WHERE (student_reference LIKE '%John%' OR 'John' = '')
--   AND (incident_type = 'Fighting' OR 'Fighting' = '')
--   AND (incident_status = 'Open' OR 'Open' = '')
--   AND occurred_on BETWEEN '2026-03-01' AND '2026-03-31'
-- ORDER BY occurred_on DESC, id DESC;