SELECT jpf.job_id,
    cd.name AS company_name,
    cd.company_id,
    jpf.job_title_short,
    jpf.job_location
FROM job_postings_fact AS jpf
    INNER JOIN company_dim AS cd ON jpf.company_id = cd.company_id;
-- juste un saut de ligne
SELECT jpf.*,
    cd.*
FROM job_postings_fact AS jpf
    LEFT JOIN company_dim AS cd ON jpf.company_id = cd.company_id
LIMIT 10;
-- juste un saut de ligne
SELECT COUNT(*)
FROM job_postings_fact;
SELECT COUNT(*)
FROM job_postings_fact AS jpf
    LEFT JOIN company_dim AS cd ON jpf.company_id = cd.company_id;
-- juste un saut de ligne
SELECT jpf.job_id,
    jpf.job_title_short,
    sjd.skill_id,
    sd.skills
FROM job_postings_fact AS jpf
    LEFT JOIN skills_job_dim as sjd ON jpf.job_id = sjd.job_id
    LEFT JOIN skills_dim AS sd ON sjd.skill_id = sd.skill_id;
-- encore un saut de ligne
SELECT jpf.job_id,
    jpf.job_title_short,
    sjd.skill_id,
    sd.skills
FROM job_postings_fact AS jpf
    INNER JOIN skills_job_dim as sjd ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim AS sd ON sjd.skill_id = sd.skill_id;