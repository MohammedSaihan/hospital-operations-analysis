-- =====================================================
-- Project: Hospital Operations & Patient Flow Analysis
-- File: healthcare_kpi_queries.sql
-- Description: SQL queries for healthcare KPI reporting
-- =====================================================

-- -----------------------------------------------------
-- 0. Preview the data
-- -----------------------------------------------------
SELECT *
FROM hospital_data
LIMIT 10;

-- -----------------------------------------------------
-- 1. Total unique patients
-- -----------------------------------------------------
SELECT COUNT(DISTINCT patient_id) AS total_patients
FROM hospital_data;

-- -----------------------------------------------------
-- 2. Total records / total visits
-- -----------------------------------------------------
SELECT COUNT(*) AS total_visits
FROM hospital_data;

-- -----------------------------------------------------
-- 3. Visits by department
-- -----------------------------------------------------
SELECT
    department,
    COUNT(*) AS total_visits
FROM hospital_data
GROUP BY department
ORDER BY total_visits DESC;

-- -----------------------------------------------------
-- 4. Monthly admissions trend
-- -----------------------------------------------------
SELECT
    DATE_FORMAT(admission_date, '%Y-%m') AS admission_month,
    COUNT(*) AS total_admissions
FROM hospital_data
GROUP BY admission_month
ORDER BY admission_month;

-- -----------------------------------------------------
-- 5. Average wait time by department
-- -----------------------------------------------------
SELECT
    department,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time
FROM hospital_data
GROUP BY department
ORDER BY avg_wait_time DESC;

-- -----------------------------------------------------
-- 6. Calculate average length of stay overall
-- Note: for inpatient records with discharge date
-- -----------------------------------------------------
SELECT
    ROUND(AVG(DATEDIFF(discharge_date, admission_date)), 2) AS avg_length_of_stay
FROM hospital_data
WHERE visit_type = 'Inpatient'
  AND discharge_date IS NOT NULL
  AND discharge_date >= admission_date;

-- -----------------------------------------------------
-- 7. Readmission rate overall
-- -----------------------------------------------------
SELECT
    ROUND(
        SUM(CASE WHEN readmitted_30_days = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate_percentage
FROM hospital_data;

-- -----------------------------------------------------
-- 8. No-show rate by department
-- -----------------------------------------------------
SELECT
    department,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN appointment_status = 'No Show' THEN 1 ELSE 0 END) AS no_show_count,
    ROUND(
        SUM(CASE WHEN appointment_status = 'No Show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate_percentage
FROM hospital_data
GROUP BY department
ORDER BY no_show_rate_percentage DESC;

-- -----------------------------------------------------
-- 9. Average treatment cost by visit type
-- -----------------------------------------------------
SELECT
    visit_type,
    ROUND(AVG(treatment_cost), 2) AS avg_treatment_cost
FROM hospital_data
GROUP BY visit_type
ORDER BY avg_treatment_cost DESC;

-- -----------------------------------------------------
-- 10. Readmission rate by age group
-- -----------------------------------------------------
SELECT
    CASE
        WHEN age < 18 THEN '0-17'
        WHEN age BETWEEN 18 AND 35 THEN '18-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        WHEN age BETWEEN 51 AND 65 THEN '51-65'
        ELSE '66+'
    END AS age_group,
    COUNT(*) AS total_visits,
    ROUND(
        SUM(CASE WHEN readmitted_30_days = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate_percentage
FROM hospital_data
GROUP BY age_group
ORDER BY age_group;

-- -----------------------------------------------------
-- 11. Inpatient vs outpatient split
-- -----------------------------------------------------
SELECT
    visit_type,
    COUNT(*) AS total_visits,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM hospital_data), 2) AS visit_percentage
FROM hospital_data
GROUP BY visit_type
ORDER BY total_visits DESC;

-- -----------------------------------------------------
-- 12. Inpatient vs outpatient split
-- -----------------------------------------------------
SELECT
    city,
    COUNT(*) AS total_visits
FROM hospital_data
GROUP BY city
ORDER BY total_visits DESC;

-- -----------------------------------------------------
-- 13. Top diagnosis categories
-- -----------------------------------------------------
SELECT
    diagnosis_category,
    COUNT(*) AS total_cases
FROM hospital_data
GROUP BY diagnosis_category
ORDER BY total_cases DESC;

-- -----------------------------------------------------
-- 14. Admission source breakdown
-- -----------------------------------------------------
SELECT
    admission_source,
    COUNT(*) AS total_visits,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM hospital_data), 2) AS percentage
FROM hospital_data
GROUP BY admission_source
ORDER BY total_visits DESC;

-- -----------------------------------------------------
-- 15. Outcome status distribution
-- -----------------------------------------------------
SELECT
    outcome_status,
    COUNT(*) AS total_cases,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM hospital_data), 2) AS percentage
FROM hospital_data
GROUP BY outcome_status
ORDER BY total_cases DESC;

-- -----------------------------------------------------
-- 16. Doctor workload
-- -----------------------------------------------------
SELECT
    doctor_id,
    COUNT(*) AS total_patients_handled
FROM hospital_data
GROUP BY doctor_id
ORDER BY total_patients_handled DESC
LIMIT 10;


-- -----------------------------------------------------
-- 17. Patient repeat visit analysis
-- -----------------------------------------------------
SELECT
    patient_id,
    COUNT(*) AS total_visits
FROM hospital_data
GROUP BY patient_id
HAVING COUNT(*) > 1
ORDER BY total_visits DESC;

-- -----------------------------------------------------
-- 18. Wait time risk flag
-- Example rule: wait time above 60 minutes
-- -----------------------------------------------------
SELECT
    department,
    COUNT(*) AS total_visits,
    SUM(CASE WHEN wait_time_minutes > 60 THEN 1 ELSE 0 END) AS high_wait_cases,
    ROUND(
        SUM(CASE WHEN wait_time_minutes > 60 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS high_wait_case_percentage
FROM hospital_data
GROUP BY department
ORDER BY high_wait_case_percentage DESC;



