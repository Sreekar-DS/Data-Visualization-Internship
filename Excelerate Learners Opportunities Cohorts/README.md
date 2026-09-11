# Excelerate Learners, Opportunities & Cohorts Analysis

An end-to-end learning analytics project completed during the Excelerate Data Visualization Early Internship. The project combines learner, identity/demographic, opportunity, cohort and enrollment data in PostgreSQL, cleans and models the data for analysis, and prepares an analytics-ready dataset for BI reporting.

## Business problem

The source data was distributed across multiple tables and contained missing profile information, inconsistent identifiers and enrollment/cohort relationships that were difficult to analyse directly. The goal was to build a reliable analytical layer that could answer questions such as:

- How many learners are enrolled versus not enrolled?
- Which opportunities attract the most learners?
- How are learners distributed across cohorts?
- Where are profile or demographic fields incomplete?
- Which countries contribute the largest learner populations?

## What I built

1. Loaded six source datasets into PostgreSQL.
2. Profiled nulls and data-quality issues with SQL.
3. Created cleaned master tables using CTEs, `COALESCE`, `CASE`, `EXTRACT`, joins and aggregations.
4. Integrated learner, Cognito/profile, opportunity and cohort data into a BI-ready master dataset.
5. Performed cohort-, opportunity- and learner-level exploratory analysis.
6. Built a Looker Studio dashboard for interactive reporting.

## Portfolio snapshot

The final analytical extract contains **184,782 rows and 42 columns**, representing **129,262 unique learners**. A privacy-safe review of the final extract found:

- **57,967 learners enrolled** in at least one opportunity and **71,295 not enrolled** (44.84% vs 55.16%).
- **187 opportunities** and **577 cohorts** represented in valid enrollment records.
- **33.16% of learners** had demographics marked as not mentioned.
- **40.77% of learners** had profile/education details marked as not mentioned.
- The largest learner countries included India, Nigeria, Pakistan, Kenya and the United States.
- The most represented opportunity was **Data Visualization Early Internship**, followed by **Project Management Early Internship**.

See [`results/portfolio_summary.md`](results/portfolio_summary.md) for the recruiter-friendly aggregate snapshot.

## SQL in this repository

- [`sql/01_data_quality_and_eda.sql`](sql/01_data_quality_and_eda.sql) — data-quality checks and cohort/opportunity analysis.
- [`sql/02_master_etl_pipeline.sql`](sql/02_master_etl_pipeline.sql) — representative PostgreSQL cleaning and transformation pipeline.
- [`sql/03_portfolio_kpis.sql`](sql/03_portfolio_kpis.sql) — compact KPI queries that reproduce the portfolio-level results.

The original internship scripts are retained in the project archive in Google Drive. The files here are curated for readability while preserving the analytical logic used in the project.

## Dataset policy

The full final CSV is approximately **149 MB** and includes learner-level identifiers and personal/profile fields. It is therefore intentionally **not published to GitHub**. This repository contains SQL, schema documentation and aggregate results instead of raw learner data. This keeps the project reviewable without exposing personal information or using Git LFS for data that should not be public.

## Dashboard

Legacy Looker Studio dashboard: https://lookerstudio.google.com/reporting/13f5c772-7e14-476d-8521-dffab2d2360c

The Looker Studio source can become unavailable as external data connections age, so the SQL and static aggregate results in this repository are the durable project record.

## Tech stack

**PostgreSQL · SQL · Data Cleaning · ETL · Data Quality · CTEs · Joins · Aggregations · Looker Studio · Learning Analytics**

## Collaboration

Completed collaboratively by **Tarun Sreekar Parasa** and **Saranya Pamarthi** during the Excelerate internship.
