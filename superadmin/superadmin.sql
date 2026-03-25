-- =============================================================
-- superadmin.sql
-- Proprietor / Promoter module
-- Pages: dashboard.html · registration.html
-- Engine: InnoDB | Charset: utf8mb4 | Target: Hostinger / phpMyAdmin
-- =============================================================

-- -------------------------------------------------------------
-- 1. SCHOOL SETTINGS  (dashboard.html – School Overview panel)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS superadmin_school_settings (
    id              TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    school_name     VARCHAR(120)     NOT NULL DEFAULT 'Kivu Sunrise Private School',
    campuses        TINYINT UNSIGNED NOT NULL DEFAULT 1,
    director_name   VARCHAR(80)      NOT NULL,
    created_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- 2. REPORTING TERMS  (dashboard.html – termSelector)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS superadmin_terms (
    id                SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    term_code         VARCHAR(12)       NOT NULL UNIQUE,   -- e.g. 2025-T1
    term_label        VARCHAR(40)       NOT NULL,          -- e.g. 2025-2026 • Term 1
    academic_year     VARCHAR(12)       NOT NULL,          -- e.g. 2025-2026
    board_review_date DATE              NULL,
    is_active         TINYINT(1)        NOT NULL DEFAULT 0,
    created_at        TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- 3. TERM METRICS  (dashboard.html – stat cards + Executive Highlights)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS superadmin_term_metrics (
    id                   INT UNSIGNED      NOT NULL AUTO_INCREMENT PRIMARY KEY,
    term_id              SMALLINT UNSIGNED NOT NULL,
    total_enrollment     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    new_admissions       SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    fee_revenue_display  VARCHAR(20)       NOT NULL DEFAULT '$0',   -- formatted label e.g. $124k
    collection_rate_pct  TINYINT UNSIGNED  NOT NULL DEFAULT 0,
    staff_count          SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    teacher_count        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    compliance_pct       TINYINT UNSIGNED  NOT NULL DEFAULT 0,
    audit_actions_open   TINYINT UNSIGNED  NOT NULL DEFAULT 0,
    pass_rate_pct        TINYINT UNSIGNED  NOT NULL DEFAULT 0,
    outstanding_fees_display VARCHAR(20)   NOT NULL DEFAULT '$0',
    retention_rate_pct   TINYINT UNSIGNED  NOT NULL DEFAULT 0,
    CONSTRAINT fk_sa_metrics_term FOREIGN KEY (term_id)
        REFERENCES superadmin_terms (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- 4. DEPARTMENT PERFORMANCE  (dashboard.html – Executive Highlights table)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS superadmin_department_performance (
    id             INT UNSIGNED      NOT NULL AUTO_INCREMENT PRIMARY KEY,
    term_id        SMALLINT UNSIGNED NOT NULL,
    department     VARCHAR(60)       NOT NULL,
    head_name      VARCHAR(80)       NOT NULL,
    performance    VARCHAR(10)       NOT NULL,   -- e.g. 86%
    status_label   VARCHAR(40)       NOT NULL,   -- e.g. Strong, Improving
    badge_color    VARCHAR(20)       NOT NULL DEFAULT 'secondary',
    sort_order     TINYINT UNSIGNED  NOT NULL DEFAULT 0,
    CONSTRAINT fk_sa_dept_term FOREIGN KEY (term_id)
        REFERENCES superadmin_terms (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- 5. FEE COLLECTION SUMMARY  (dashboard.html – Fee Collection Summary table)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS superadmin_fee_collection (
    id               INT UNSIGNED      NOT NULL AUTO_INCREMENT PRIMARY KEY,
    term_id          SMALLINT UNSIGNED NOT NULL,
    class_group      VARCHAR(60)       NOT NULL,   -- e.g. Nursery & Primary
    expected_amount  VARCHAR(20)       NOT NULL DEFAULT '$0',
    collected_amount VARCHAR(20)       NOT NULL DEFAULT '$0',
    balance_amount   VARCHAR(20)       NOT NULL DEFAULT '$0',
    sort_order       TINYINT UNSIGNED  NOT NULL DEFAULT 0,
    CONSTRAINT fk_sa_fees_term FOREIGN KEY (term_id)
        REFERENCES superadmin_terms (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- 6. MANAGEMENT TASKS  (dashboard.html – Management Tasks panel)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS superadmin_management_tasks (
    id          INT UNSIGNED      NOT NULL AUTO_INCREMENT PRIMARY KEY,
    term_id     SMALLINT UNSIGNED NOT NULL,
    title       VARCHAR(120)      NOT NULL,
    due_label   VARCHAR(30)       NOT NULL DEFAULT 'This week',  -- e.g. Today, Tomorrow
    priority    ENUM('High','Medium','Low') NOT NULL DEFAULT 'Medium',
    is_done     TINYINT(1)        NOT NULL DEFAULT 0,
    created_at  TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sa_tasks_term FOREIGN KEY (term_id)
        REFERENCES superadmin_terms (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- 7. KEY ANNOUNCEMENTS  (dashboard.html – Key Announcements panel)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS superadmin_announcements (
    id          INT UNSIGNED      NOT NULL AUTO_INCREMENT PRIMARY KEY,
    term_id     SMALLINT UNSIGNED NOT NULL,
    title       VARCHAR(120)      NOT NULL,
    detail      TEXT              NOT NULL,
    created_at  TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sa_announce_term FOREIGN KEY (term_id)
        REFERENCES superadmin_terms (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- 8. LEADERSHIP ACCOUNTS  (registration.html)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS superadmin_leadership_accounts (
    id                INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    role              ENUM('Principal','Director','Deputy Director') NOT NULL,
    full_name         VARCHAR(80)  NOT NULL,
    phone             VARCHAR(25)  NOT NULL,
    emergency_contact VARCHAR(80)  NOT NULL,
    password_hash     VARCHAR(255) NOT NULL,   -- store bcrypt / Argon2 hash, NEVER plain text
    notes             TEXT         NULL,
    registered_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active         TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Audit log: track who registered each leadership account
CREATE TABLE IF NOT EXISTS superadmin_registration_audit (
    id              INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    leadership_id   INT UNSIGNED NOT NULL,
    action          VARCHAR(30)  NOT NULL DEFAULT 'REGISTERED',
    performed_by    VARCHAR(80)  NULL,
    performed_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes           TEXT         NULL,
    CONSTRAINT fk_sa_audit_leadership FOREIGN KEY (leadership_id)
        REFERENCES superadmin_leadership_accounts (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================
-- VIEW – dashboard snapshot (active term)
-- =============================================================
DROP VIEW IF EXISTS vw_superadmin_dashboard_snapshot;
CREATE VIEW vw_superadmin_dashboard_snapshot AS
SELECT
    t.term_code,
    t.term_label,
    t.academic_year,
    t.board_review_date,
    s.school_name,
    s.campuses,
    s.director_name,
    m.total_enrollment,
    m.new_admissions,
    m.fee_revenue_display,
    m.collection_rate_pct,
    m.staff_count,
    m.teacher_count,
    m.compliance_pct,
    m.audit_actions_open,
    m.pass_rate_pct,
    m.outstanding_fees_display,
    m.retention_rate_pct
FROM superadmin_terms          t
JOIN superadmin_term_metrics   m ON m.term_id = t.id
JOIN superadmin_school_settings s ON s.id = 1
WHERE t.is_active = 1
LIMIT 1;

-- =============================================================
-- SEED DATA
-- =============================================================

-- School settings
INSERT INTO superadmin_school_settings (school_name, campuses, director_name)
VALUES ('Kivu Sunrise Private School', 2, 'Mr. Joel Mbuyi')
ON DUPLICATE KEY UPDATE
    school_name   = VALUES(school_name),
    campuses      = VALUES(campuses),
    director_name = VALUES(director_name);

-- Terms
INSERT INTO superadmin_terms (term_code, term_label, academic_year, board_review_date, is_active)
VALUES
    ('2025-T1', '2025-2026 • Term 1', '2025-2026', '2026-03-28', 0),
    ('2025-T2', '2025-2026 • Term 2', '2025-2026', '2026-06-18', 1)
ON DUPLICATE KEY UPDATE
    term_label        = VALUES(term_label),
    academic_year     = VALUES(academic_year),
    board_review_date = VALUES(board_review_date),
    is_active         = VALUES(is_active);

-- Term metrics – T1
INSERT INTO superadmin_term_metrics
    (term_id, total_enrollment, new_admissions, fee_revenue_display, collection_rate_pct,
     staff_count, teacher_count, compliance_pct, audit_actions_open,
     pass_rate_pct, outstanding_fees_display, retention_rate_pct)
SELECT id, 824, 96, '$124k', 88, 61, 44, 92, 3, 84, '$17k', 95
FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE total_enrollment = VALUES(total_enrollment);

-- Term metrics – T2
INSERT INTO superadmin_term_metrics
    (term_id, total_enrollment, new_admissions, fee_revenue_display, collection_rate_pct,
     staff_count, teacher_count, compliance_pct, audit_actions_open,
     pass_rate_pct, outstanding_fees_display, retention_rate_pct)
SELECT id, 841, 28, '$131k', 91, 63, 46, 95, 1, 87, '$12k', 96
FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE total_enrollment = VALUES(total_enrollment);

-- Department performance – T1
INSERT INTO superadmin_department_performance (term_id, department, head_name, performance, status_label, badge_color, sort_order)
SELECT id, 'Academics',      'Mrs. Chantal Ilunga', '86%', 'Strong',          'success',  1 FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE status_label = VALUES(status_label);
INSERT INTO superadmin_department_performance (term_id, department, head_name, performance, status_label, badge_color, sort_order)
SELECT id, 'Finance',        'Mr. Patrick Kasongo', '88%', 'Stable',          'primary',  2 FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE status_label = VALUES(status_label);
INSERT INTO superadmin_department_performance (term_id, department, head_name, performance, status_label, badge_color, sort_order)
SELECT id, 'Discipline',     'Mr. Daniel Banza',    '81%', 'Needs Follow-up', 'warning',  3 FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE status_label = VALUES(status_label);
INSERT INTO superadmin_department_performance (term_id, department, head_name, performance, status_label, badge_color, sort_order)
SELECT id, 'Administration', 'Ms. Ruth Mukendi',    '90%', 'On Track',        'success',  4 FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE status_label = VALUES(status_label);

-- Department performance – T2
INSERT INTO superadmin_department_performance (term_id, department, head_name, performance, status_label, badge_color, sort_order)
SELECT id, 'Academics',      'Mrs. Chantal Ilunga', '89%', 'Strong',     'success', 1 FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE status_label = VALUES(status_label);
INSERT INTO superadmin_department_performance (term_id, department, head_name, performance, status_label, badge_color, sort_order)
SELECT id, 'Finance',        'Mr. Patrick Kasongo', '92%', 'Excellent',  'success', 2 FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE status_label = VALUES(status_label);
INSERT INTO superadmin_department_performance (term_id, department, head_name, performance, status_label, badge_color, sort_order)
SELECT id, 'Discipline',     'Mr. Daniel Banza',    '84%', 'Improving',  'info',    3 FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE status_label = VALUES(status_label);
INSERT INTO superadmin_department_performance (term_id, department, head_name, performance, status_label, badge_color, sort_order)
SELECT id, 'Administration', 'Ms. Ruth Mukendi',    '93%', 'On Track',   'success', 4 FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE status_label = VALUES(status_label);

-- Fee collection – T1
INSERT INTO superadmin_fee_collection (term_id, class_group, expected_amount, collected_amount, balance_amount, sort_order)
SELECT id, 'Nursery & Primary',  '$38,000', '$33,600', '$4,400', 1 FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE collected_amount = VALUES(collected_amount);
INSERT INTO superadmin_fee_collection (term_id, class_group, expected_amount, collected_amount, balance_amount, sort_order)
SELECT id, 'Lower Secondary',    '$46,000', '$40,900', '$5,100', 2 FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE collected_amount = VALUES(collected_amount);
INSERT INTO superadmin_fee_collection (term_id, class_group, expected_amount, collected_amount, balance_amount, sort_order)
SELECT id, 'Upper Secondary',    '$57,000', '$50,100', '$6,900', 3 FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE collected_amount = VALUES(collected_amount);

-- Fee collection – T2
INSERT INTO superadmin_fee_collection (term_id, class_group, expected_amount, collected_amount, balance_amount, sort_order)
SELECT id, 'Nursery & Primary',  '$39,500', '$36,700', '$2,800', 1 FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE collected_amount = VALUES(collected_amount);
INSERT INTO superadmin_fee_collection (term_id, class_group, expected_amount, collected_amount, balance_amount, sort_order)
SELECT id, 'Lower Secondary',    '$48,400', '$44,900', '$3,500', 2 FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE collected_amount = VALUES(collected_amount);
INSERT INTO superadmin_fee_collection (term_id, class_group, expected_amount, collected_amount, balance_amount, sort_order)
SELECT id, 'Upper Secondary',    '$58,900', '$53,200', '$5,700', 3 FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE collected_amount = VALUES(collected_amount);

-- Management tasks – T1
INSERT INTO superadmin_management_tasks (term_id, title, due_label, priority)
SELECT id, 'Approve revised transport budget',      'Today',     'High'   FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE due_label = VALUES(due_label);
INSERT INTO superadmin_management_tasks (term_id, title, due_label, priority)
SELECT id, 'Review bursar fee recovery plan',       'Tomorrow',  'High'   FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE due_label = VALUES(due_label);
INSERT INTO superadmin_management_tasks (term_id, title, due_label, priority)
SELECT id, 'Validate next term staffing proposal',  'This week', 'Medium' FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE due_label = VALUES(due_label);
INSERT INTO superadmin_management_tasks (term_id, title, due_label, priority)
SELECT id, 'Sign ministry compliance letter',       'This week', 'Medium' FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE due_label = VALUES(due_label);

-- Management tasks – T2
INSERT INTO superadmin_management_tasks (term_id, title, due_label, priority)
SELECT id, 'Approve classroom furniture purchase',        'Today',     'High'   FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE due_label = VALUES(due_label);
INSERT INTO superadmin_management_tasks (term_id, title, due_label, priority)
SELECT id, 'Review teacher recruitment shortlist',        'Tomorrow',  'High'   FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE due_label = VALUES(due_label);
INSERT INTO superadmin_management_tasks (term_id, title, due_label, priority)
SELECT id, 'Confirm exam security budget',                'This week', 'Medium' FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE due_label = VALUES(due_label);
INSERT INTO superadmin_management_tasks (term_id, title, due_label, priority)
SELECT id, 'Inspect girls dormitory maintenance report',  'This week', 'Low'    FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE due_label = VALUES(due_label);

-- Announcements – T1
INSERT INTO superadmin_announcements (term_id, title, detail)
SELECT id, 'School inspection scheduled',   'Provincial inspection team expected on Mar 21.'         FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE detail = VALUES(detail);
INSERT INTO superadmin_announcements (term_id, title, detail)
SELECT id, 'Science lab renovation approved', 'Works start during the holiday break.'               FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE detail = VALUES(detail);
INSERT INTO superadmin_announcements (term_id, title, detail)
SELECT id, 'Fee payment extension',         'Extension granted to families affected by delayed salaries.' FROM superadmin_terms WHERE term_code = '2025-T1'
ON DUPLICATE KEY UPDATE detail = VALUES(detail);

-- Announcements – T2
INSERT INTO superadmin_announcements (term_id, title, detail)
SELECT id, 'Term 2 exam preparation underway', 'Printing and supervision plans have started.'       FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE detail = VALUES(detail);
INSERT INTO superadmin_announcements (term_id, title, detail)
SELECT id, 'Fee recovery improved',          'Outstanding balance reduced by 29% compared to Term 1.' FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE detail = VALUES(detail);
INSERT INTO superadmin_announcements (term_id, title, detail)
SELECT id, 'Teacher housing support proposal', 'Draft package submitted for promoter review.'       FROM superadmin_terms WHERE term_code = '2025-T2'
ON DUPLICATE KEY UPDATE detail = VALUES(detail);
