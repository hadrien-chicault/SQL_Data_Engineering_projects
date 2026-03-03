USE data_jobs;
--array Intro
SELECT [1,2,3];
SELECT ['python','sql','r'] AS skills_array;
WITH skills AS (
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
),
skills_array AS (
    SELECT ARRAY_AGG(
            skill
            ORDER BY skill
        ) AS skills
    From skills
)
SELECT skills [1] AS first_skill,
    skills [2] AS second_skill,
    skills [3] AS third_skill
FROM skills_array;
-- struct
SELECT { skill: 'python',
    type: 'programming' } AS skill_struct;
WITH skills_struck AS (
    SELECT STRUCT_PACK(skill := 'python', type := 'programming') AS s
)
SELECT s.skill,
    S.type
FROM skills_struck;
--
WITH skill_table AS(
    SELECT 'python' AS skills,
        'programming' AS types
    UNION ALL
    SELECT 'sql',
        'query_language'
    UNION ALL
    SELECT 'r',
        'programming'
)
SELECT STRUCt_PACK(skill := skills, type := types)
FROM skill_table;
-- array of structs
SELECT [
    {
        skill: 'python', type:'programming'
    },
    {skill: 'sql', type: 'query_language'}
] AS skills_array_of_struct;
--
WITH skill_table AS(
    SELECT 'python' AS skills,
        'programming' AS types
    UNION ALL
    SELECT 'sql',
        'query_language'
    UNION ALL
    SELECT 'r',
        'programming'
),
skills_array_struct AS (
    SELECT ARRAY_AGG(STRUCT_PACK(skill := skills, type := types)) AS array_struct
    FROM skill_table
)
SELECT array_struct [1].skill,
    array_struct [2].type,
    array_struct [3]
FROM skills_array_struct;
-- map
WITH skill_map AS (
    SELECT MAP { 'skill': 'python',
        'type' :'programming' } AS skill_type
)
SELECT skill_type ['skill'],
    skill_type ['type']
FROM skill_map;
-- JSON
WITH raw_skill_json AS (
    SELECT '{"skill":"python","type":"programming"}'::JSON AS skill_json
)
SELECT STRUCT_PACK(
        skill := json_extract_string(skill_json, '$.skill'),
        type := json_extract_string(skill_json, '$.type')
    )
FROM raw_skill_json;
-- JSON to Array os Struct
WITH raw_json AS (
    SELECT '[
{"skill":"pyton","type":"programming"},
{"skill":"sql","type":"query_language"},
{"skill":"r","type":"programming"}
]'::JSON as skill_json
)
SELECT ARRAY_AGG(
        STRUCT_PACK(
            skill := json_extract_string(e.value, '$.skill'),
            type := json_extract_string(e.value, '$.type')
        )
        ORDER BY json_extract_string(e.value, '$.skill')
    ) AS skills
FROM raw_json,
    json_each(skill_json) AS e;
-- ARRAY final
CREATE OR REPLACE TEMP TABLE job_skills_array AS
SELECT jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS skills_array
FROM job_postings_fact AS JPF
    LEFT JOIN skills_job_dim AS sjd ON jpf.job_id = sjd.job_id
    LEFT JOIN skills_dim AS sd ON sd.skill_id = sjd.skill_id
GROUP BY ALL;
-- From the perspective of a data Analyst, analyse the median salary per skill
WITH flat_skills AS (
    SELECT job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_array) AS skill
    FROM job_skills_array
)
SELECT skill,
    MEDIAN(salary_year_avg) as median_salary
FROM flat_skills
GROUP BY skill
ORDER BY median_salary DESC;
-- Build a flat skill & type table for the co-workers to access job title, salary info, and ty in one table
SELECT *
FROM skills_dim
LIMIT 20;
--
CREATE OR REPLACE TEMP TABLE job_skills_array_struct AS
SELECT jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(
        STRUCT_PACK(skill_type := sd.type, skill_name := sd.skills)
    ) AS skill_types
FROM job_postings_fact AS JPF
    LEFT JOIN skills_job_dim AS sjd ON jpf.job_id = sjd.job_id
    LEFT JOIN skills_dim AS sd ON sd.skill_id = sjd.skill_id
GROUP BY ALL;
--
WITH flat_skills AS (
    SELECT job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skill_types).skill_type AS skill_type,
        UNNEST(skill_types).skill_name AS skill_name
    FROM job_skills_array_struct
)
SELECT skill_type,
    MEDIAN(salary_year_avg) as median_salary
FROM flat_skills
GROUP BY skill_type;