# Data Visualization Internship — Analytics Portfolio

**Authors:** Tarun Sreekar Parasa (Sreekar-DS) & Saranya Pamarthi (Saranya-DA)

This repository contains two end-to-end analytics projects completed during the **Excelerate Data Visualization Early Internship**. Together they demonstrate PostgreSQL data preparation, analytical SQL, BI reporting, Excel/Tableau analysis and business-facing recommendations.

## Projects

### 1. Excelerate Learners, Opportunities & Cohorts Analysis

A large learning-analytics project that integrated learner, profile, cohort, opportunity and enrollment data in PostgreSQL and prepared a clean analytical model for BI reporting.

**Highlights**
- PostgreSQL ETL and data-quality analysis across six source datasets.
- Final analytical extract: **184,782 rows × 42 columns** and **129,262 unique learners**.
- CTEs, joins, conditional logic, null handling, date transformations and aggregations.
- Cohort utilization, opportunity popularity, enrollment and learner-profile analysis.
- Looker Studio reporting, with durable static results stored in the repository.
- Raw learner data is intentionally excluded because the ~149 MB extract contains personal/profile fields.

**Project:** [Excelerate Learners Opportunities Cohorts](./Excelerate%20Learners%20Opportunities%20Cohorts/)

**Legacy Looker Studio dashboard:** https://lookerstudio.google.com/reporting/13f5c772-7e14-476d-8521-dffab2d2360c

### 2. Superhero U Event — Facebook Ads Campaign Analysis

A marketing-performance case study evaluating **11 campaigns across 13 countries** to identify inefficient spend and support campaign-removal / budget-reallocation decisions.

**Highlights**
- Excel-based campaign analysis.
- Tableau dashboard for campaign comparison.
- Recommendation to remove/reallocate underperforming campaigns, with an estimated **~30% budget saving** in the internship scenario.

**Project:** [Superhero U Event - Facebook Ads Campaign Analysis](./Superhero%20U%20Event%20-%20Facebook%20Ads%20Campaign%20Analysis/)

**Tableau Public:** https://public.tableau.com/app/profile/tarun.sreekar.parasa3476/viz/DVT15Week-2Deliverable/CAMPAIGNWISETOTALREACH?publish=yes

## Skills demonstrated

**PostgreSQL · SQL · ETL · Data Cleaning · Data Quality · CTEs · Joins · Aggregations · Excel · Tableau · Looker Studio · KPI Design · Business Analysis · Data Visualization**

## Data and reproducibility

The small marketing workbook is included in the Superhero U project. The large learner-level dataset is not published because it contains personal/profile fields and is unnecessary for portfolio review. The learner project instead includes curated SQL, transformation documentation and privacy-safe aggregate results so the analytical work can still be inspected directly on GitHub.

## Collaboration

Both internship projects were completed collaboratively by **Tarun Sreekar Parasa** and **Saranya Pamarthi**.
