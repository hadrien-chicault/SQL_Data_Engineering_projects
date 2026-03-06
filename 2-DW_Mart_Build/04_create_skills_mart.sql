DROP SCHEMA IF EXISTS skills_mart CASCADE;

-- Step 1: Create the mart schema
CREATE SCHEMA skills_mart;

-- Step 2: Create dimension tables

-- 1. Skills dimension
CREATE TABLE skills_mart.dim_skill (
    skill_id INTEGER PRIMARY KEY,
    skills VARCHAR,
    type VARCHAR
);

INSERT INTO skills_mart.dim_skill (skill_id, skills, type)
SELECT
    skill_id,
    skills,
    type
FROM skills_dim;

-- 2. Month-level date dimension (enhanced with quarter and other attributes)
CREATE TABLE skills_mart.dim_date_month (
    month_start_date DATE PRIMARY KEY,
    year INTEGER,
    month INTEGER,
    quarter INTEGER,
    quarter_name VARCHAR,
    year_quarter VARCHAR
);

INSERT INTO skills_mart.dim_date_month (
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_quarter
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date)::DATE AS month_start_date,
    EXTRACT(year FROM job_posted_date) AS year,
    EXTRACT(month FROM job_posted_date) AS month,
    EXTRACT(quarter FROM job_posted_date) AS quarter,
    -- Quarter name
    'Q' || CAST(EXTRACT(quarter FROM job_posted_date) AS VARCHAR) AS quarter_name,
    -- Year-Quarter combination for easy filtering
    CAST(EXTRACT(year FROM job_posted_date) AS VARCHAR) || '-Q' ||
    CAST(EXTRACT(quarter FROM job_posted_date) AS VARCHAR) AS year_quarter
FROM job_postings_fact
WHERE job_posted_date IS NOT NULL;

-- Step 3: Create fact table - fact_skill_demand_monthly
-- Grain: skill_id + month_start_date + job_title_short
-- All measures are additive (counts and sums) - safe to re-aggregate
CREATE TABLE skills_mart.fact_skill_demand_monthly (
    skill_id INTEGER,
    month_start_date DATE,
    job_title_short VARCHAR,
    postings_count INTEGER,
    remote_postings_count INTEGER,
    health_insurance_postings_count INTEGER,
    no_degree_mention_count INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skills_mart.dim_skill(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month(month_start_date)
);

INSERT INTO skills_mart.fact_skill_demand_monthly (
    skill_id,
    month_start_date,
    job_title_short,
    postings_count,
    remote_postings_count,
    health_insurance_postings_count,
    no_degree_mention_count
)
WITH job_postings_prepared AS (
    SELECT
        sj.skill_id,
        DATE_TRUNC('month', jp.job_posted_date)::DATE AS month_start_date,
        jp.job_title_short,
        -- Convert boolean flags to numeric values (1 or 0)
        CASE WHEN jp.job_work_from_home = TRUE THEN 1 ELSE 0 END AS is_remote,
        CASE WHEN jp.job_health_insurance = TRUE THEN 1 ELSE 0 END AS has_health_insurance,
        CASE WHEN jp.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_mention
    FROM
        job_postings_fact jp
    INNER JOIN
        skills_job_dim sj
        ON jp.job_id = sj.job_id
    WHERE
        jp.job_posted_date IS NOT NULL
)
SELECT
    skill_id,
    month_start_date,
    job_title_short,

    -- Additive counts
    COUNT(*) AS postings_count,

    -- Remote / benefits / degree flags (additive counts)
    SUM(is_remote) AS remote_postings_count,
    SUM(has_health_insurance) AS health_insurance_postings_count,
    SUM(no_degree_mention) AS no_degree_mention_count
FROM
    job_postings_prepared
GROUP BY
    skill_id,
    month_start_date,
    job_title_short;
------------------------------------------- DATA QUALITY CHECKS --------------------------------------------------------------
SELECT '=== Numbers of rows  Check ===' AS info;
SELECT 'skills_mart.fact_skill_demand_monthly' AS origin_table,
    COUNT(*) AS row_numbers
FROM skills_mart.fact_skill_demand_monthly
UNION ALL
SELECT 'skills_mart.dim_skill' AS origin_table,
    COUNT(*) AS row_numbers
FROM skills_mart.dim_skill
UNION ALL
SELECT 'skills_mart.dim_date_month' AS origin_table,
    COUNT(*) AS row_numbers
FROM skills_mart.dim_date_month;

SELECT '=== Referential Integrity Check ===' AS info;
SELECT 'Orphaned skill_id in skills_mart.fact_skill_demand_monthly' AS check_type,
    COUNT(*) AS orphaned_count
FROM skills_mart.fact_skill_demand_monthly
WHERE skill_id NOT IN (
        SELECT skill_id
        FROM skills_mart.dim_skill
    )
UNION ALL
SELECT 'Orphaned month_start_date in skills_mart.fact_skill_demand_monthly' AS check_type,
    COUNT(*) AS orphaned_count
FROM skills_mart.fact_skill_demand_monthly
WHERE month_start_date NOT IN (
        SELECT month_start_date
        FROM skills_mart.dim_date_month
    );
-- Show sample data
SELECT '=== skills_mart.fact_skill_demand_monthly Sample ===' AS info;
SELECT *
FROM skills_mart.fact_skill_demand_monthly
LIMIT 5;
SELECT '=== skills_mart.dim_skill Dimension Sample ===' AS info;
SELECT *
FROM skills_mart.dim_skill
LIMIT 5;
SELECT '=== skills_mart.dim_date_month Sample ===' AS info;
SELECT *
FROM skills_mart.dim_date_month
LIMIT 5;
