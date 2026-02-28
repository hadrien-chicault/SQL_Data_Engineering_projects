USE data_jobs;
-- Length & Count
SELECT LENGTH('SQL');
-- UPPER AND LOWER
SELECT LOWER('SQL');
SELECT UPPER('Sql');
-- LEFT RIGHT SUBSTRING
SELECT LEFT('SQL', 2);
SELECT RIGHT('SQL', 2);
SELECT SUBSTRING('SQL', 2, 1);
-- CONCATENATION CONCAT ou ||
SELECT CONCAT('SQL', '-', 'Functions');
SELECT 'SQL' || '-' || 'Functions';
-- TRIMMING TRIM LTRIM RTRIM
SELECT TRIM(' SQL ');
SELECT LTRIM(' SQL ');
SELECT RTRIM(' SQL ');
-- Replacement
SELECT REPLACE ('SQL', 'Q', '_');
SELECT REGEXP_REPLACE('SQL', '[A-Z]+', 'sql');
--
WITH title_lower AS (
    SELECT job_title,
        LOWER(TRIM(job_title)) AS job_title_clean
    FROM job_postings_fact
)
SELECT job_title,
    CASE
        WHEN job_title_clean LIKE '%data%'
        AND job_title_clean LIKE '%Analyst%' THEN 'Data Analyst'
        WHEN job_title_clean LIKE '%data%'
        AND job_title_clean LIKE '%scientist%' THEN 'Data Scientist'
        WHEN job_title_clean LIKE 'data%'
        AND job_title_clean LIKE '%engineer%' THEN 'Data Engineer'
        ELSE 'Other'
    END AS job_title_dategory
FROM title_lower
ORDER BY RANDOM()
LIMIT 30;
-- NULL FUNTIONS NULLIF
SELECT NULLIF(10, 10);
SELECT NULLIF(10, 20);
SELECT NULLIF(salary_year_avg, 0) AS salary_year_avg,
    NULLIF(salary_hour_avg, 0) AS salary_hour_avg
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
    OR salary_year_avg IS NOT NULL
LIMIT 10;
-- COALESCE
SELECT COALESCE(NULL, 1, 2);
SELECT salary_year_avg,
    salary_hour_avg,
    COALESCE(
        salary_year_avg,
        salary_hour_avg * 2080,
    )
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
    OR salary_year_avg IS NOT NULL
LIMIT 10;
--
SELECT job_title_short,
    salary_year_avg,
    salary_hour_avg,
    COALESCE(
        salary_year_avg,
        salary_hour_avg * 2080,
    ) AS standardized_salary,
    CASE
        WHEN COALESCE(
            salary_year_avg,
            salary_hour_avg * 2080,
        ) IS NULL THEN 'Missing'
        WHEN COALESCE(
            salary_year_avg,
            salary_hour_avg * 2080,
        ) < 75_000 THEN 'Low'
        WHEN COALESCE(
            salary_year_avg,
            salary_hour_avg * 2080,
        ) < 150_000 THEN 'Mid'
        ELSE 'High'
    END AS salary_bucket
FROM job_postings_fact
ORDER BY standardized_salary DESC;