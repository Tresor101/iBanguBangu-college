-- Hostinger-compatible schema (MySQL 8 / MariaDB) aligned with:
-- - student-registration.html
-- - student-id-entry.html
-- - parent-dashboard.html (parent can have multiple children)
-- - student-dashboard.html

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS parents (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(255) NOT NULL,
    occupation VARCHAR(120) NOT NULL,
    address TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_parents_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS students (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    -- IDs from form (must be equal, and non-editable in UI)
    student_id VARCHAR(30) NOT NULL,
    admission_no VARCHAR(30) NOT NULL,

    -- Student basic information
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    gender ENUM('male', 'female') NOT NULL,
    date_of_birth DATE NOT NULL,
    place_of_birth VARCHAR(150) NOT NULL,
    nationality VARCHAR(100) NOT NULL,

    -- Uploaded photo metadata
    photo_filename VARCHAR(255) NOT NULL,
    photo_mime_type VARCHAR(100),
    photo_storage_path TEXT NOT NULL,

    -- Contact information
    home_address TEXT NOT NULL,
    city_commune VARCHAR(120) NOT NULL,
    province VARCHAR(120) NOT NULL,
    country VARCHAR(120) NOT NULL,
    student_email VARCHAR(255),

    -- Academic information
    admission_date DATE NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    class_grade VARCHAR(50) NOT NULL,
    section VARCHAR(50),
    previous_school VARCHAR(200) NOT NULL,
    last_grade_completed VARCHAR(80) NOT NULL,

    -- Emergency information
    emergency_contact_name VARCHAR(150) NOT NULL,
    emergency_contact_phone VARCHAR(30) NOT NULL,
    medical_conditions TEXT,
    allergies TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_students_student_id (student_id),
    UNIQUE KEY uq_students_admission_no (admission_no),
    KEY idx_students_class_grade (class_grade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_parent_links (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id BIGINT UNSIGNED NOT NULL,
    parent_id BIGINT UNSIGNED NOT NULL,
    relationship_to_student VARCHAR(80) NOT NULL,
    is_primary TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_student_parent (student_id, parent_id),
    KEY idx_student_parent_links_student (student_id),
    KEY idx_student_parent_links_parent (parent_id),
    CONSTRAINT fk_student_parent_links_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_student_parent_links_parent FOREIGN KEY (parent_id) REFERENCES parents(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS subjects (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(120) NOT NULL,
    code VARCHAR(30),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_subjects_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS teachers (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    teacher_code VARCHAR(30) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(30),
    specialization VARCHAR(120),
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_teachers_code (teacher_code),
    UNIQUE KEY uq_teachers_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS management_roles (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    role_code VARCHAR(40) NOT NULL,
    role_name VARCHAR(120) NOT NULL,
    role_category ENUM('management', 'academic', 'finance', 'administration') NOT NULL DEFAULT 'management',
    description TEXT,
    is_core_role TINYINT(1) NOT NULL DEFAULT 1,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_management_roles_code (role_code),
    UNIQUE KEY uq_management_roles_name (role_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS management_staff (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    staff_code VARCHAR(30) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    gender ENUM('male', 'female') NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(255),
    address TEXT,
    hire_date DATE,
    employment_status ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_management_staff_code (staff_code),
    UNIQUE KEY uq_management_staff_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS management_staff_role_assignments (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    management_staff_id BIGINT UNSIGNED NOT NULL,
    management_role_id BIGINT UNSIGNED NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    is_primary_role TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_management_role_assignment (management_staff_id, management_role_id, start_date),
    KEY idx_management_role_assignments_role (management_role_id),
    CONSTRAINT fk_msra_staff FOREIGN KEY (management_staff_id) REFERENCES management_staff(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_msra_role FOREIGN KEY (management_role_id) REFERENCES management_roles(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_msra_dates CHECK (end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS classes (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    class_code VARCHAR(40) NOT NULL,
    class_grade VARCHAR(50) NOT NULL,
    section VARCHAR(50),
    academic_year VARCHAR(20) NOT NULL,
    room_label VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_classes_code_year (class_code, academic_year),
    KEY idx_classes_grade_year (class_grade, academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS teacher_class_subjects (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    teacher_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NOT NULL,
    subject_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_teacher_class_subject (teacher_id, class_id, subject_id),
    KEY idx_teacher_class_subjects_class (class_id),
    CONSTRAINT fk_tcs_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tcs_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tcs_subject FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS class_student_enrollments (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    class_id BIGINT UNSIGNED NOT NULL,
    student_id BIGINT UNSIGNED NOT NULL,
    roll_no VARCHAR(20),
    enrolled_at DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_class_student (class_id, student_id),
    KEY idx_class_student_enrollments_student (student_id),
    CONSTRAINT fk_cse_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cse_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS class_sessions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    class_id BIGINT UNSIGNED NOT NULL,
    subject_id BIGINT UNSIGNED,
    teacher_id BIGINT UNSIGNED,
    session_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    status ENUM('scheduled', 'completed', 'cancelled') NOT NULL DEFAULT 'scheduled',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_class_sessions_class_date (class_id, session_date),
    CONSTRAINT fk_class_sessions_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_class_sessions_subject FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_class_sessions_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_class_session_time CHECK (end_time IS NULL OR start_time IS NULL OR end_time > start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS class_session_attendance (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    session_id BIGINT UNSIGNED NOT NULL,
    student_id BIGINT UNSIGNED NOT NULL,
    attendance_status ENUM('present', 'absent', 'late', 'excused') NOT NULL,
    note VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_session_student_attendance (session_id, student_id),
    KEY idx_class_session_attendance_student (student_id),
    CONSTRAINT fk_csa_session FOREIGN KEY (session_id) REFERENCES class_sessions(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_csa_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS class_assignments (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    class_id BIGINT UNSIGNED NOT NULL,
    subject_id BIGINT UNSIGNED,
    teacher_id BIGINT UNSIGNED,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    assigned_date DATE NOT NULL,
    due_date DATE NOT NULL,
    max_score DECIMAL(5,2) DEFAULT 100,
    status ENUM('active', 'closed') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_class_assignments_class_due (class_id, due_date),
    CONSTRAINT fk_class_assignments_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_class_assignments_subject FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_class_assignments_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_class_assignment_dates CHECK (due_date >= assigned_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS assignment_submissions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    assignment_id BIGINT UNSIGNED NOT NULL,
    student_id BIGINT UNSIGNED NOT NULL,
    submitted_at DATETIME,
    submission_status ENUM('pending', 'submitted', 'late', 'missing', 'graded') NOT NULL DEFAULT 'pending',
    score DECIMAL(5,2),
    feedback TEXT,
    graded_by_teacher_id BIGINT UNSIGNED,
    graded_at DATETIME,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_assignment_submission_student (assignment_id, student_id),
    KEY idx_assignment_submissions_status (submission_status),
    CONSTRAINT fk_assignment_submissions_assignment FOREIGN KEY (assignment_id) REFERENCES class_assignments(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_assignment_submissions_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_assignment_submissions_grader FOREIGN KEY (graded_by_teacher_id) REFERENCES teachers(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_assignment_score CHECK (score IS NULL OR (score >= 0 AND score <= 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS teacher_tasks (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    teacher_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED,
    task_title VARCHAR(200) NOT NULL,
    due_date DATE,
    status ENUM('todo', 'in_progress', 'done') NOT NULL DEFAULT 'todo',
    priority ENUM('low', 'medium', 'high') NOT NULL DEFAULT 'medium',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_teacher_tasks_teacher_status (teacher_id, status),
    CONSTRAINT fk_teacher_tasks_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_teacher_tasks_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_subject_results (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id BIGINT UNSIGNED NOT NULL,
    subject_id BIGINT UNSIGNED NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    term_label VARCHAR(30),
    score DECIMAL(5,2) NOT NULL,
    grade VARCHAR(10) NOT NULL,
    remark VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_student_subject_term (student_id, subject_id, academic_year, term_label),
    KEY idx_results_student_year (student_id, academic_year),
    CONSTRAINT fk_results_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_results_subject FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_results_score CHECK (score >= 0 AND score <= 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_attendance_summaries (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id BIGINT UNSIGNED NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    term_label VARCHAR(30),
    present_days INT NOT NULL,
    total_days INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_attendance_summary (student_id, academic_year, term_label),
    KEY idx_attendance_student_year (student_id, academic_year),
    CONSTRAINT fk_attendance_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_attendance_days CHECK (present_days >= 0 AND total_days > 0 AND present_days <= total_days)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_fee_balances (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id BIGINT UNSIGNED NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    balance_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    currency_code CHAR(3) NOT NULL DEFAULT 'USD',
    due_date DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_fee_balance (student_id, academic_year),
    KEY idx_fees_student_year (student_id, academic_year),
    CONSTRAINT fk_fees_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_balance_amount CHECK (balance_amount >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS class_schedules (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id BIGINT UNSIGNED NOT NULL,
    day_of_week TINYINT UNSIGNED NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    subject_id BIGINT UNSIGNED,
    room_label VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_schedule_student_day (student_id, day_of_week),
    CONSTRAINT fk_schedule_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_schedule_subject FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_schedule_day CHECK (day_of_week BETWEEN 1 AND 7),
    CONSTRAINT chk_schedule_time CHECK (end_time > start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_assignments (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(200) NOT NULL,
    due_date DATE NOT NULL,
    status ENUM('pending', 'submitted', 'late') NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_assignments_student_status (student_id, status),
    CONSTRAINT fk_assignments_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS announcements (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    audience ENUM('student', 'parent', 'teacher', 'management', 'both', 'all') NOT NULL,
    publish_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_announcements_audience_date (audience, publish_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO management_roles (role_code, role_name, role_category, description, is_core_role, display_order)
VALUES
    ('PROPRIETOR', 'Proprietor / Promoter', 'management', 'School owner or promoter responsible for strategic oversight.', 1, 1),
    ('DIRECTOR', 'School Director', 'management', 'Overall head of the school operations and compliance.', 1, 2),
    ('DEPUTY_DIRECTOR', 'Deputy Director', 'management', 'Supports the school director in daily administration.', 1, 3),
    ('ACADEMIC_DIRECTOR', 'Academic Director / Prefect of Studies', 'academic', 'Oversees academic programs, teaching quality, and timetables.', 1, 4),
    ('DISCIPLINE_OFFICER', 'Discipline Officer / Prefect', 'administration', 'Manages discipline, student conduct, and school order.', 1, 5),
    ('BURSAR', 'Bursar / Accountant', 'finance', 'Handles school fees, accounting, and financial records.', 1, 6),
    ('REGISTRAR', 'Registrar / Secretary', 'administration', 'Manages admissions, records, and official school correspondence.', 1, 7),
    ('HR_ADMIN', 'Human Resources / Administration Officer', 'administration', 'Coordinates staff administration, HR records, and office operations.', 1, 8)
ON DUPLICATE KEY UPDATE
    role_name = VALUES(role_name),
    role_category = VALUES(role_category),
    description = VALUES(description),
    is_core_role = VALUES(is_core_role),
    display_order = VALUES(display_order);

-- Business-rule triggers for Hostinger MySQL/MariaDB
DROP TRIGGER IF EXISTS trg_students_validate_before_insert;
DROP TRIGGER IF EXISTS trg_students_validate_before_update;

DELIMITER $$

CREATE TRIGGER trg_students_validate_before_insert
BEFORE INSERT ON students
FOR EACH ROW
BEGIN
    IF NEW.student_id <> NEW.admission_no THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'student_id and admission_no must be the same';
    END IF;

    IF NEW.student_id NOT REGEXP '^STU-[0-9]{8}-[0-9]{4}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'student_id must match format STU-YYYYMMDD-####';
    END IF;

    IF NEW.date_of_birth > DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
       OR NEW.date_of_birth < DATE_SUB(CURDATE(), INTERVAL 23 YEAR) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student age must be between 2 and 23 years';
    END IF;
END$$

CREATE TRIGGER trg_students_validate_before_update
BEFORE UPDATE ON students
FOR EACH ROW
BEGIN
    IF NEW.student_id <> NEW.admission_no THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'student_id and admission_no must be the same';
    END IF;

    IF NEW.student_id NOT REGEXP '^STU-[0-9]{8}-[0-9]{4}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'student_id must match format STU-YYYYMMDD-####';
    END IF;

    IF NEW.date_of_birth > DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
       OR NEW.date_of_birth < DATE_SUB(CURDATE(), INTERVAL 23 YEAR) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student age must be between 2 and 23 years';
    END IF;
END$$

DELIMITER ;

-- Useful query examples:
-- 1) Student lookup for "Check Result" page
-- SELECT id, student_id, first_name, last_name, class_grade, academic_year
-- FROM students
-- WHERE student_id = ?;

-- 2) Parent dashboard children list
-- SELECT s.id, s.student_id, s.first_name, s.last_name, s.class_grade, s.academic_year
-- FROM students s
-- JOIN student_parent_links spl ON spl.student_id = s.id
-- JOIN parents p ON p.id = spl.parent_id
-- WHERE p.email = ?
-- ORDER BY s.first_name, s.last_name;

-- 3) Student dashboard results
-- SELECT sub.name AS subject, r.score, r.grade, r.remark
-- FROM student_subject_results r
-- JOIN subjects sub ON sub.id = r.subject_id
-- JOIN students s ON s.id = r.student_id
-- WHERE s.student_id = ? AND r.academic_year = ?
-- ORDER BY sub.name;

-- 4) Teacher dashboard class overview (students, attendance today, pending grading)
-- SELECT
--   c.id AS class_id,
--   c.class_code,
--   c.class_grade,
--   c.section,
--   COUNT(DISTINCT cse.student_id) AS total_students,
--   ROUND(
--     100 * SUM(CASE WHEN csa.attendance_status = 'present' THEN 1 ELSE 0 END)
--     / NULLIF(COUNT(csa.id), 0),
--     2
--   ) AS attendance_today_percent,
--   SUM(CASE WHEN sub.submission_status IN ('pending', 'submitted', 'late') THEN 1 ELSE 0 END) AS pending_grading
-- FROM classes c
-- JOIN teacher_class_subjects tcs ON tcs.class_id = c.id
-- LEFT JOIN class_student_enrollments cse ON cse.class_id = c.id
-- LEFT JOIN class_sessions cs ON cs.class_id = c.id AND cs.session_date = CURDATE()
-- LEFT JOIN class_session_attendance csa ON csa.session_id = cs.id
-- LEFT JOIN class_assignments ca ON ca.class_id = c.id AND ca.status = 'active'
-- LEFT JOIN assignment_submissions sub ON sub.assignment_id = ca.id
-- WHERE tcs.teacher_id = ? AND c.academic_year = ?
-- GROUP BY c.id, c.class_code, c.class_grade, c.section
-- ORDER BY c.class_grade, c.section;

-- 5) Core management roles configured for a private school in DR Congo
-- SELECT role_code, role_name, role_category, display_order
-- FROM management_roles
-- WHERE is_core_role = 1
-- ORDER BY display_order, role_name;

-- 6) Active management staff with their current roles
-- SELECT
--   ms.staff_code,
--   ms.full_name,
--   mr.role_name,
--   mr.role_category,
--   ms.phone,
--   ms.email
-- FROM management_staff ms
-- JOIN management_staff_role_assignments msra ON msra.management_staff_id = ms.id
-- JOIN management_roles mr ON mr.id = msra.management_role_id
-- WHERE ms.employment_status = 'active'
--   AND (msra.end_date IS NULL OR msra.end_date >= CURDATE())
-- ORDER BY mr.display_order, ms.full_name;
