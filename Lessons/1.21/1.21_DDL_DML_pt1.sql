-- .read ./Lessons/1.21/1.21_DDL_DML_pt1.sql
USE data_jobs;
DROP DATABASE IF EXISTS jobs_mart;
CREATE DATABASE IF NOT EXISTS jobs_mart;
-- DROP DATABASE IF EXISTS jobs_mart;
--
SHOW DATABASES;
--
-- DROP DATABASE IF EXISTS jobs_mart;
--
SELECT *
FROM information_schema.schemata;
--
USE jobs_mart;
--
CREATE SCHEMA IF NOT EXISTS jobs_mart.staging;
--DROP SCHEMA staging;
CREATE TABLE IF NOT EXISTS staging.preferred_roles(role_id INTEGER PRIMARY KEY, role_name VARCHAR);
--
--DROP TABLE IF EXISTS staging.preferred_roles;
--
SELECT *
FROM information_schema.tables
where table_catalog = 'jobs_mart';
--
--DROP TABLE  main.preferred_roles;
--
INSERT INTO staging.preferred_roles (role_id, role_name)
VALUES (1, 'Data Engineer'),
    (2, 'Senior Data Engineer'),
    (3, 'Software Engineer');
--
SELECT *
FROM staging.preferred_roles;
--
ALTER TABLE IF EXISTS staging.preferred_roles
ADD COLUMN preferred_role BOOLEAN;
--ALTER TABLE IF EXISTS staging.preferred_roles DROP COLUMN preferred_role;
--
UPDATE staging.preferred_roles --
SET preferred_role = TRUE
WHERE role_id = 1
    OR role_id = 2;
--
UPDATE staging.preferred_roles --
SET preferred_role = FALSE
WHERE role_id = 3;
--
ALTER TABLE staging.preferred_roles
    RENAME TO priority_roles;
--
ALTER TABLE staging.priority_roles
    RENAME COLUMN preferred_role TO priority_lvl;
--
ALTER TABLE staging.priority_roles
ALTER COLUMN priority_lvl TYPE INTEGER;
--
UPDATE staging.priority_roles
SET priority_lvl = 3
WHERE role_id = 3;
--
SELECT *
FROM staging.priority_roles;