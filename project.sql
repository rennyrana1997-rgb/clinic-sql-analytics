-- ===================================================
-- HEALTHCARE CLINIC APPOINTMENT & FLOW ANALYTICS (PostgreSQL)
-- ===================================================

-- 1. CLEANUP (Drop tables if they already exist)
DROP TABLE IF EXISTS clinical_encounters CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS providers CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- 2. CREATE TABLES
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    clinic_location VARCHAR(100) NOT NULL
);

CREATE TABLE providers (
    provider_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department_id INT REFERENCES departments(department_id),
    provider_role VARCHAR(50) NOT NULL
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    provider_id INT REFERENCES providers(provider_id),
    department_id INT REFERENCES departments(department_id),
    booking_date DATE NOT NULL,
    scheduled_date DATE NOT NULL,
    appointment_status VARCHAR(20) CHECK (appointment_status IN ('Completed', 'No-Show', 'Cancelled'))
);

CREATE TABLE clinical_encounters (
    encounter_id INT PRIMARY KEY,
    appointment_id INT REFERENCES appointments(appointment_id),
    check_in_time TIMESTAMP NOT NULL,
    doctor_seen_time TIMESTAMP NOT NULL,
    discharge_time TIMESTAMP NOT NULL
);

-- 3. INSERT SAMPLE DATA
INSERT INTO departments VALUES
(1, 'Internal Medicine', 'Main Clinic'),
(2, 'Cardiology', 'Heart Center'),
(3, 'Pediatrics', 'West Wing');

INSERT INTO providers VALUES
(101, 'Marcus', 'Vance', 1, 'Physician'),
(102, 'Elena', 'Rostova', 1, 'Nurse Practitioner'),
(103, 'David', 'Kim', 2, 'Cardiologist');

INSERT INTO appointments VALUES
(1001, 501, 101, 1, '2026-10-01', '2026-10-15', 'Completed'),
(1002, 502, 101, 1, '2026-09-10', '2026-10-15', 'No-Show'),
(1003, 503, 102, 1, '2026-10-12', '2026-10-15', 'Completed'),
(1004, 504, 103, 2, '2026-08-20', '2026-10-15', 'No-Show'),
(1005, 505, 103, 2, '2026-10-14', '2026-10-15', 'Completed');

INSERT INTO clinical_encounters VALUES
(1, 1001, '2026-10-15 08:30:00', '2026-10-15 08:55:00', '2026-10-15 09:20:00'),
(2, 1003, '2026-10-15 09:00:00', '2026-10-15 09:12:00', '2026-10-15 09:35:00'),
(3, 1005, '2026-10-15 10:15:00', '2026-10-15 10:45:00', '2026-10-15 11:15:00');

-- ===================================================
-- 4. ANALYTICAL BUSINESS QUERIES
-- ===================================================

-- Query 1: Do appointments booked far in advance have higher No-Show rates?
SELECT 
    CASE 
        WHEN (scheduled_date - booking_date) <= 3 THEN '0-3 Days (Short Lead)'
        WHEN (scheduled_date - booking_date) <= 14 THEN '4-14 Days (Medium Lead)'
        ELSE '15+ Days (Long Lead)'
    END AS lead_time_category,
    COUNT(*) AS total_appointments,
    COUNT(CASE WHEN appointment_status = 'No-Show' THEN 1 END) AS total_no_shows,
    ROUND(
        100.0 * COUNT(CASE WHEN appointment_status = 'No-Show' THEN 1 END) / COUNT(*), 
        1
    ) AS noshow_rate_pct
FROM appointments
GROUP BY 1
ORDER BY noshow_rate_pct DESC;

-- Query 2: Which department has the longest patient wait times before seeing a doctor?
SELECT 
    d.department_name,
    COUNT(e.encounter_id) AS total_patients_seen,
    ROUND(AVG(EXTRACT(EPOCH FROM (e.doctor_seen_time - e.check_in_time)) / 60.0), 1) AS avg_waiting_room_minutes,
    ROUND(AVG(EXTRACT(EPOCH FROM (e.discharge_time - e.doctor_seen_time)) / 60.0), 1) AS avg_time_with_doctor_minutes
FROM clinical_encounters e
JOIN appointments a ON e.appointment_id = a.appointment_id
JOIN departments d ON a.department_id = d.department_id
GROUP BY d.department_name;

-- Query 3: Provider Performance Summary
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS provider_name,
    p.provider_role,
    COUNT(a.appointment_id) AS total_scheduled,
    COUNT(CASE WHEN a.appointment_status = 'Completed' THEN 1 END) AS total_completed
FROM providers p
LEFT JOIN appointments a ON p.provider_id = a.provider_id
GROUP BY p.provider_id, p.first_name, p.last_name, p.provider_role;