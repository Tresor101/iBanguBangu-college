-- Hostinger-compatible schema (MySQL 8 / MariaDB) for:
-- - teacher/dashboard.html
--
-- Features:
-- - Teacher-owned class records
-- - Class student roster
-- - Attendance tracking
-- - Assignment publishing and submissions
-- - Gradebook entries and remarks
-- - Views for dashboard widgets (subject average, pending grading, top performers)

SET NAMES utf8mb4;

-- --------------------------------------------------
-- Core tables
-- --------------------------------------------------

CREATE TABLE IF NOT EXISTS teacher_classes (
    class_id VARCHAR(30) NOT NULL,
    class_name VARCHAR(80) NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    teacher_name VARCHAR(150) NOT NULL,
    next_session_at DATETIME NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (class_id),
    KEY idx_teacher_classes_subject (subject_name),
    KEY idx_teacher_classes_active (is_active),
    KEY idx_teacher_classes_next_session (next_session_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS teacher_students (
    student_id VARCHAR(30) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    admission_no VARCHAR(50) NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id),
    KEY idx_teacher_students_full_name (full_name),
    KEY idx_teacher_students_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS teacher_class_students (
    class_id VARCHAR(30) NOT NULL,
    student_id VARCHAR(30) NOT NULL,
    enrolled_on DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (class_id, student_id),
    KEY idx_teacher_class_students_student (student_id),
    CONSTRAINT fk_teacher_class_students_class
        FOREIGN KEY (class_id)
        REFERENCES teacher_classes(class_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_teacher_class_students_student
        FOREIGN KEY (student_id)
        REFERENCES teacher_students(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------
-- Teaching workflow tables
-- --------------------------------------------------

CREATE TABLE IF NOT EXISTS teacher_attendance (
    attendance_id BIGINT NOT NULL AUTO_INCREMENT,
    class_id VARCHAR(30) NOT NULL,
    student_id VARCHAR(30) NOT NULL,
    attendance_date DATE NOT NULL,
    attendance_status ENUM('present', 'absent', 'late', 'excused') NOT NULL DEFAULT 'present',
    remarks VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (attendance_id),
    UNIQUE KEY uq_teacher_attendance_unique (class_id, student_id, attendance_date),
    KEY idx_teacher_attendance_class_date (class_id, attendance_date),
    KEY idx_teacher_attendance_student_date (student_id, attendance_date),
    CONSTRAINT fk_teacher_attendance_class
        FOREIGN KEY (class_id)
        REFERENCES teacher_classes(class_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_teacher_attendance_student
        FOREIGN KEY (student_id)
        REFERENCES teacher_students(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS teacher_assignments (
    assignment_id VARCHAR(30) NOT NULL,
    class_id VARCHAR(30) NOT NULL,
    title VARCHAR(160) NOT NULL,
    description TEXT NULL,
    assigned_on DATE NOT NULL,
    due_on DATE NULL,
    max_marks DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    is_published TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (assignment_id),
    KEY idx_teacher_assignments_class_due (class_id, due_on),
    KEY idx_teacher_assignments_published (is_published),
    CONSTRAINT fk_teacher_assignments_class
        FOREIGN KEY (class_id)
        REFERENCES teacher_classes(class_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS teacher_assignment_submissions (
    submission_id BIGINT NOT NULL AUTO_INCREMENT,
    assignment_id VARCHAR(30) NOT NULL,
    student_id VARCHAR(30) NOT NULL,
    submitted_at DATETIME NULL,
    submission_status ENUM('not_submitted', 'submitted', 'late') NOT NULL DEFAULT 'not_submitted',
    score DECIMAL(5,2) NULL,
    graded_at DATETIME NULL,
    teacher_comment TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (submission_id),
    UNIQUE KEY uq_teacher_assignment_submission (assignment_id, student_id),
    KEY idx_teacher_submissions_status (submission_status),
    KEY idx_teacher_submissions_graded_at (graded_at),
    CONSTRAINT fk_teacher_submissions_assignment
        FOREIGN KEY (assignment_id)
        REFERENCES teacher_assignments(assignment_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_teacher_submissions_student
        FOREIGN KEY (student_id)
        REFERENCES teacher_students(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS teacher_gradebook (
    grade_id BIGINT NOT NULL AUTO_INCREMENT,
    class_id VARCHAR(30) NOT NULL,
    student_id VARCHAR(30) NOT NULL,
    mark DECIMAL(5,2) NOT NULL,
    remark VARCHAR(150) NULL,
    graded_on DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (grade_id),
    KEY idx_teacher_gradebook_class (class_id),
    KEY idx_teacher_gradebook_student (student_id),
    KEY idx_teacher_gradebook_graded_on (graded_on),
    CONSTRAINT fk_teacher_gradebook_class
        FOREIGN KEY (class_id)
        REFERENCES teacher_classes(class_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_teacher_gradebook_student
        FOREIGN KEY (student_id)
        REFERENCES teacher_students(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------
-- Validation triggers
-- --------------------------------------------------

DROP TRIGGER IF EXISTS trg_teacher_gradebook_mark_validate_insert;
DROP TRIGGER IF EXISTS trg_teacher_gradebook_mark_validate_update;

DELIMITER $$

CREATE TRIGGER trg_teacher_gradebook_mark_validate_insert
BEFORE INSERT ON teacher_gradebook
FOR EACH ROW
BEGIN
    IF NEW.mark < 0 OR NEW.mark > 100 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Grade mark must be between 0 and 100.';
    END IF;
END$$

CREATE TRIGGER trg_teacher_gradebook_mark_validate_update
BEFORE UPDATE ON teacher_gradebook
FOR EACH ROW
BEGIN
    IF NEW.mark < 0 OR NEW.mark > 100 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Grade mark must be between 0 and 100.';
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------
-- Dashboard helper views
-- --------------------------------------------------

-- Class-level average score (for selected class in dashboard).
DROP VIEW IF EXISTS vw_teacher_class_subject_average;
CREATE VIEW vw_teacher_class_subject_average AS
SELECT
    c.class_id,
    c.class_name,
    c.subject_name,
    ROUND(AVG(g.mark), 2) AS subject_average
FROM teacher_classes c
LEFT JOIN teacher_gradebook g ON g.class_id = c.class_id
GROUP BY c.class_id, c.class_name, c.subject_name;

-- Pending grading count based on submitted assignment work without score.
DROP VIEW IF EXISTS vw_teacher_pending_grading;
CREATE VIEW vw_teacher_pending_grading AS
SELECT
    a.class_id,
    COUNT(*) AS pending_grading_count
FROM teacher_assignment_submissions s
INNER JOIN teacher_assignments a ON a.assignment_id = s.assignment_id
WHERE s.submission_status IN ('submitted', 'late')
  AND s.score IS NULL
GROUP BY a.class_id;

-- Top performers by average score per class.
DROP VIEW IF EXISTS vw_teacher_top_performers;
CREATE VIEW vw_teacher_top_performers AS
SELECT
    c.class_id,
    s.student_id,
    s.full_name,
    ROUND(AVG(g.mark), 2) AS average_score
FROM teacher_gradebook g
INNER JOIN teacher_students s ON s.student_id = g.student_id
INNER JOIN teacher_classes c ON c.class_id = g.class_id
GROUP BY c.class_id, s.student_id, s.full_name;

-- --------------------------------------------------
-- Optional starter data (commented)
-- --------------------------------------------------
-- INSERT INTO teacher_classes (class_id, class_name, subject_name, teacher_name, next_session_at)
-- VALUES ('CLS-10A-MATH', 'Grade 10 - A', 'Mathematics', 'Ms. Sarah Smith', '2026-03-26 08:00:00');
--
-- INSERT INTO teacher_students (student_id, full_name, admission_no)
-- VALUES
-- ('STU-20260304-1234', 'John Doe', 'ADM-001'),
-- ('STU-20260304-5678', 'Anne Kabedi', 'ADM-002');
--
-- INSERT INTO teacher_class_students (class_id, student_id, enrolled_on)
-- VALUES
-- ('CLS-10A-MATH', 'STU-20260304-1234', CURDATE()),
-- ('CLS-10A-MATH', 'STU-20260304-5678', CURDATE());
