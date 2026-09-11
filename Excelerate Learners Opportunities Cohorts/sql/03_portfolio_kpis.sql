-- Excelerate Learners, Opportunities & Cohorts Analysis
-- Portfolio KPI queries for the curated master model
-- PostgreSQL

-- 1. Learner population and enrollment rate.
SELECT
    COUNT(DISTINCT learner_id) AS unique_learners,
    COUNT(DISTINCT learner_id) FILTER (WHERE enrollment_status = 'Enrolled') AS enrolled_learners,
    COUNT(DISTINCT learner_id) FILTER (WHERE enrollment_status = 'Not Enrolled') AS not_enrolled_learners,
    ROUND(
        100.0 * COUNT(DISTINCT learner_id) FILTER (WHERE enrollment_status = 'Enrolled')
        / NULLIF(COUNT(DISTINCT learner_id), 0),
        2
    ) AS enrollment_rate_pct
FROM "DVA_MASTER"."vw_learning_analytics";

-- 2. Most popular opportunities by unique enrolled learners.
SELECT
    opportunity_name,
    opportunity_category,
    COUNT(DISTINCT learner_id) AS unique_learners,
    COUNT(DISTINCT assigned_cohort) AS cohorts
FROM "DVA_MASTER"."vw_learning_analytics"
WHERE opportunity_id IS NOT NULL
GROUP BY opportunity_name, opportunity_category
ORDER BY unique_learners DESC
LIMIT 10;

-- 3. Learner distribution by country.
SELECT
    country,
    COUNT(DISTINCT learner_id) AS unique_learners
FROM "DVA_MASTER"."vw_learning_analytics"
WHERE country IS NOT NULL
  AND country <> 'NOT MENTIONED'
GROUP BY country
ORDER BY unique_learners DESC
LIMIT 15;

-- 4. Cohort utilization snapshot.
SELECT
    assigned_cohort,
    MAX(cohort_size) AS configured_size,
    COUNT(DISTINCT learner_id) AS assigned_learners,
    MAX(cohort_size) - COUNT(DISTINCT learner_id) AS remaining_capacity
FROM "DVA_MASTER"."vw_learning_analytics"
WHERE assigned_cohort IS NOT NULL
GROUP BY assigned_cohort
ORDER BY assigned_learners DESC;

-- 5. Monthly applications/enrollments trend.
SELECT
    DATE_TRUNC('month', apply_date)::date AS month,
    COUNT(*) AS enrollment_records,
    COUNT(DISTINCT learner_id) AS unique_learners,
    COUNT(DISTINCT opportunity_id) AS active_opportunities
FROM "DVA_MASTER"."vw_learning_analytics"
WHERE apply_date IS NOT NULL
GROUP BY 1
ORDER BY 1;
