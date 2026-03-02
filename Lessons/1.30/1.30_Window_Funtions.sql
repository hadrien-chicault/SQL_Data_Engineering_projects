USE data_jobs;
-- count tows - aggregated
SELECT COUNT(*)
FROM job_postings_fact;
--- Count rows - window Funtion
SELECT job_id,
    COUNT(*) OVER() AS count
FROM job_postings_fact;
-- Syntax PARTITION BY
SELECT job_id,
    job_title_short,
    company_id,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER(PARTITION BY job_title_short, company_id)
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
ORDER BY RANDOM()
LIMIT 10;
-- Syntax ORDER BY
SELECT job_id,
    COUNT(*) OVER() AS count
FROM job_postings_fact;
-- Syntax PARTITION BY
SELECT job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER(
        ORDER BY salary_hour_avg DESC
    ) AS rank_hourly_salary
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
ORDER BY salary_hour_avg DESC
LIMIT 10;
-- COMBINE le order BY fait une moyenne glissante du coup
SELECT job_id,
    job_title_short,
    salary_hour_avg,
    job_posted_date,
    AVG(salary_hour_avg) OVER(
        PARTITION BY job_title_short
        ORDER BY job_posted_date
    ) AS running_avg_hourly_by_title
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
    AND job_title_short = 'Data Engineer'
ORDER BY job_title_short,
    job_posted_date
LIMIT 10;
--
SELECT job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER(
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC
    ) AS rank_hourly_salary
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
ORDER BY salary_hour_avg DESC,
    job_title_short
LIMIT 10;
-- INteressant, le min et max sont conseves tant que le chiffre est le meilleur pour la fonctoin, le SUm fit une somme cumulée
SELECT job_id,
    job_title_short,
    salary_hour_avg,
    job_posted_date,
    MAX(salary_hour_avg) OVER(
        PARTITION BY job_title_short
        ORDER BY job_posted_date
    ) AS running_avg_hourly_by_title
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
    AND job_title_short = 'Data Engineer'
ORDER BY job_title_short,
    job_posted_date
LIMIT 10;
--
SELECT job_id,
    job_title_short,
    salary_hour_avg,
    DENSE_RANK() OVER(
        ORDER BY salary_hour_avg DESC
    ) AS rank_hourly_salary
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
ORDER BY salary_hour_avg DESC
LIMIT 140;
-- row_number
SELECT *,
    ROW_NUMBER() OVER(
        ORDER BY job_posted_date
    )
FROM job_postings_fact
ORDER BY job_posted_date
LIMIT 20;
-- navigation functions
SELECT job_id,
    company_id,
    job_title,
    job_title_short,
    salary_year_avg,
    LAG(salary_year_avg) OVER(
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS next_posting_salary,
    salary_year_avg - LAG(salary_year_avg) OVER(
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS salary_change
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY company_id,
    job_posted_date
LIMIT 60;