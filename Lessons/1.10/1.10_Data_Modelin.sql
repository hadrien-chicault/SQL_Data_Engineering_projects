SELECT job_id,
    job_title_short,
    salary_year_avg,
    company_id
FROM job_postings_fact
LIMIT 10;
SELECT *
FROM skills_job_dim
LIMIT 5;
SELECT *
FROM skills_dim
LIMIT 5;
SELECT *
FROM information_schema.key_column_usage
WHERE table_catalog = 'data_jobs';
PRAGMA show_tables_expanded;
DESCRIBE skills_job_dim;

