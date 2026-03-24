-- Hostinger-compatible schema (MySQL 8 / MariaDB) for:
-- - bursary/bursar-dashboard.html
-- Features:
-- - Record payment updates from the dashboard form
-- - Support currencies: USD, CDF (Congolese Franc), EUR
-- - Provide summary views for top dashboard cards

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS bursary_payments (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    -- Optional relation to the existing students table in student_registration_schema.sql
    -- Keep nullable because the UI currently allows free text student reference.
    student_db_id BIGINT UNSIGNED NULL,

    -- Captures the exact value typed in "Student Name / ID"
    student_reference VARCHAR(150) NOT NULL,

    amount DECIMAL(12,2) NOT NULL,
    currency ENUM('USD', 'CDF', 'EUR') NOT NULL,

    payment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    payment_time TIME NOT NULL DEFAULT (CURRENT_TIME),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_bursary_payments_date_currency (payment_date, currency),
    KEY idx_bursary_payments_student_reference (student_reference),

    CONSTRAINT chk_bursary_payments_amount_positive CHECK (amount > 0),
    CONSTRAINT fk_bursary_payments_student
        FOREIGN KEY (student_db_id)
        REFERENCES students(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------
-- Dashboard helper views
-- -----------------------------

-- Collected this term grouped by currency.
CREATE OR REPLACE VIEW vw_bursary_collected_term AS
SELECT
    currency,
    SUM(amount) AS collected_total
FROM bursary_payments
WHERE YEAR(payment_date) = YEAR(CURRENT_DATE)
GROUP BY currency;

-- Payments today.
CREATE OR REPLACE VIEW vw_bursary_payments_today AS
SELECT
    payment_date,
    COUNT(*) AS payments_count
FROM bursary_payments
WHERE payment_date = CURRENT_DATE
GROUP BY payment_date;

-- Outstanding balance tracked live from form (data attributes in bursar-dashboard.js).
-- This view is optional; the dashboard uses client-side tracking for now.

-- Suggested write pattern (Form → DB → Dashboard):
-- 1) Page load: SELECT SUM(amount) as collected_total FROM vw_bursary_collected_term WHERE currency = 'USD';
-- 2) Form submit: INSERT INTO bursary_payments (student_reference, amount, currency) VALUES ('Student Name', 500.00, 'USD');
-- 3) Dashboard updates live stats via data attributes in bursar-dashboard.js (no secondary queries needed).
