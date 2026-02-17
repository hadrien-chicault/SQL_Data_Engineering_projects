/*
 Question: What are the most optimal skills for data engineers—balancing both demand and salary?
 - Create a ranking column that combines demand count and median salary to identify the most valuable skills.
 - Focus only on remote Data Engineer positions with specified annual salaries.
 - Why?
 - This approach highlights skills that balance market demand and financial reward. It weights core skills appropriately instead of letting rare, outlier skills distort the results.
 - The natural log transformation ensures that both high-salary and widely in-demand skills surface as the most practical and valuable to learn for data engineering careers.
 */
SELECT sd.skills,
    ROUND(MEDIAN(jpf.salary_year_avg), 0) AS median_salary,
    COUNT(jpf.*) AS demand_count,
    ROUND(LN(COUNT(jpf.*)), 1) as ln_demand_count,
    ROUND(
        (MEDIAN(jpf.salary_year_avg) * LN(COUNT(jpf.*))) / 1_000_000,
        2
    ) AS optimal_score
FROM job_postings_fact as jpf
    INNER JOIN skills_job_dim as sjd ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim as sd ON sjd.skill_id = sd.skill_id
WHERE jpf.job_title_short = 'Data Engineer'
    AND jpf.job_work_from_home = TRUE
    and jpf.salary_year_avg IS NOT NULL
GROUP BY sd.skills
HAVING COUNT(jpf.*) > 100
ORDER BY optimal_score DESC
LIMIT 25;
/*
 ┌────────────┬───────────────┬──────────────┬─────────────────┬───────────────┐
 │   skills   │ median_salary │ demand_count │ ln_demand_count │ optimal_score │
 │  varchar   │    double     │    int64     │     double      │    double     │
 ├────────────┼───────────────┼──────────────┼─────────────────┼───────────────┤
 │ terraform  │      184000.0 │          193 │             5.3 │          0.97 │
 │ python     │      135000.0 │         1133 │             7.0 │          0.95 │
 │ sql        │      130000.0 │         1128 │             7.0 │          0.91 │
 │ aws        │      137320.0 │          783 │             6.7 │          0.91 │
 │ airflow    │      150000.0 │          386 │             6.0 │          0.89 │
 │ spark      │      140000.0 │          503 │             6.2 │          0.87 │
 │ snowflake  │      135500.0 │          438 │             6.1 │          0.82 │
 │ kafka      │      145000.0 │          292 │             5.7 │          0.82 │
 │ azure      │      128000.0 │          475 │             6.2 │          0.79 │
 │ java       │      135000.0 │          303 │             5.7 │          0.77 │
 │ scala      │      137290.0 │          247 │             5.5 │          0.76 │
 │ kubernetes │      150500.0 │          147 │             5.0 │          0.75 │
 │ git        │      140000.0 │          208 │             5.3 │          0.75 │
 │ databricks │      132750.0 │          266 │             5.6 │          0.74 │
 │ redshift   │      130000.0 │          274 │             5.6 │          0.73 │
 │ gcp        │      136000.0 │          196 │             5.3 │          0.72 │
 │ nosql      │      134415.0 │          193 │             5.3 │          0.71 │
 │ hadoop     │      135000.0 │          198 │             5.3 │          0.71 │
 │ pyspark    │      140000.0 │          152 │             5.0 │           0.7 │
 │ docker     │      135000.0 │          144 │             5.0 │          0.67 │
 │ mongodb    │      135750.0 │          136 │             4.9 │          0.67 │
 │ go         │      140000.0 │          113 │             4.7 │          0.66 │
 │ r          │      134775.0 │          133 │             4.9 │          0.66 │
 │ bigquery   │      135000.0 │          123 │             4.8 │          0.65 │
 │ github     │      135000.0 │          127 │             4.8 │          0.65 │
 ├────────────┴───────────────┴──────────────┴─────────────────┴───────────────┤
 │ 25 rows                                                           5 columns │
 └─────────────────────────────────────────────────────────────────────────────
 */
/*
 📊 Synthèse : Compétences Data Engineer en Remote (avec salaire)
 🎯 Contexte de l'analyse
 Périmètre : Postes Data Engineer en remote avec salaire publié, ayant >100 occurrences
 Métrique clé : optimal_score = (salaire médian × ln(demande)) / 1M
 🏆 Top 5 des compétences à ROI optimal
 
 Terraform (0.97) - IaC devenu indispensable, 184K$ médian
 Python (0.95) - Langage universel, 1,133 postes
 SQL (0.91) - Fondamental absolu, 1,128 postes
 AWS (0.91) - Cloud leader, 137K$ médian, 783 postes
 Airflow (0.89) - Orchestration standard, 150K$ médian
 
 💡 Insights détaillés
 La formule logarithmique révèle :
 
 Le ln(demand) pénalise les compétences ultra-communes (plafond de croissance)
 Terraform : forte rémunération + demande raisonnable = meilleur équilibre
 Python/SQL : score élevé malgré ln car salaire × volume compensent
 
 Stratégies salariales distinctes :
 Premium rareté (salaire élevé, demande modérée) :
 
 Terraform (184K$, 193 postes) → Infrastructure as Code
 Kubernetes (150.5K$, 147 postes) → Orchestration conteneurs
 Kafka (145K$, 292 postes) → Streaming temps réel
 
 Volume massif (demande énorme, salaire solide) :
 
 Python (135K$, 1,133 postes)
 SQL (130K$, 1,128 postes)
 AWS (137K$, 783 postes)
 
 Écosystèmes identifiés :
 Stack Cloud Native (scores 0.75-0.97) :
 
 Terraform + Kubernetes + Docker + AWS/Azure/GCP
 
 Stack Big Data (scores 0.70-0.89) :
 
 Spark/PySpark + Airflow + Kafka + Hadoop
 
 Stack Data Warehouse (scores 0.73-0.82) :
 
 Snowflake + Redshift + Databricks + BigQuery
 
 🎓 Recommandations stratégiques
 Profil junior → mid :
 
 Maîtriser : Python + SQL (fondations, demande massive)
 Ajouter : AWS + Airflow (accès aux postes remote)
 Différencier : Terraform ou Spark (salaire premium)
 
 Profil senior :
 
 Combo gagnant : Terraform + Kubernetes + AWS (IaC + DevOps)
 Alternative Big Data : Spark + Kafka + Airflow (streaming/orchestration)
 
 Signaux du marché :
 
 Infrastructure moderne bat "Big Data classique" en rémunération
 Remote = compétences cloud obligatoires (AWS/Azure/GCP tous présents)
 Orchestration (Airflow, Kubernetes) = différenciateur clé
 
 ⚠️ Ce que le ln(demand) cache :
 Python et SQL ont un ln faible relatif (7.0) car 1,133 postes → ln plafonne la croissance exponentielle. Mais leur volume absolu reste déterminant pour l'employabilité réelle.
 Conclusion : Terraform offre le meilleur ratio valeur/compétition, mais Python+SQL restent les portes d'entrée incontournables du marché Data Engineer remote.
 */