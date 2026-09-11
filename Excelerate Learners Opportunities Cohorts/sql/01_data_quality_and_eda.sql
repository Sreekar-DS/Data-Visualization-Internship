-- Excelerate Learners, Opportunities & Cohorts Analysis
-- Portfolio extract: data-quality and exploratory analysis queries
-- PostgreSQL

-- 1. Measure completeness of learner-opportunity records.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE learner_id IS NOT NULL
          AND assigned_cohort IS NOT NULL
          AND apply_date IS NOT NULL
          AND status IS NOT NULL
    ) AS complete_rows,
    COUNT(*) - COUNT(*) FILTER (
        WHERE learner_id IS NOT NULL
          AND assigned_cohort IS NOT NULL
          AND apply_date IS NOT NULL
          AND status IS NOT NULL
    ) AS incomplete_rows
FROM "DVA"."Learner_Opportunity_Data";

-- 2. Compare actual learner assignments with the configured cohort size.
WITH cohort_activity AS (
    SELECT
        assigned_cohort,
        COUNT(enrollment_id) AS learner_assignments,
        COUNT(DISTINCT learner_id) AS opportunities_in_cohort
    FROM "DVA"."Learner_Opportunity_Data"
    WHERE assigned_cohort IS NOT NULL
      AND apply_date IS NOT NULL
      AND status IS NOT NULL
    GROUP BY assigned_cohort
)
SELECT
    ca.assigned_cohort,
    ca.learner_assignments,
    ca.opportunities_in_cohort,
    c.size AS configured_cohort_size,
    c.size - ca.learner_assignments AS capacity_difference,
    ROUND(
        ABS((c.size - ca.learner_assignments)::numeric * 100 / NULLIF(c.size, 0)),
        2
    ) AS capacity_difference_pct
FROM cohort_activity ca
JOIN "DVA"."Cohort_Data" c
  ON ca.assigned_cohort = c.cohort_code
ORDER BY configured_cohort_size DESC;

-- 3. Find opportunities that span the largest number of cohorts.
-- Note: the source system's learner_id field in Learner_Opportunity_Data
-- stores the opportunity identifier; the alias below makes its business meaning explicit.
WITH opportunity_activity AS (
    SELECT
        learner_id AS opportunity_id,
        COUNT(enrollment_id) AS learner_assignments,
        COUNT(DISTINCT assigned_cohort) AS cohort_count
    FROM "DVA"."Learner_Opportunity_Data"
    WHERE assigned_cohort IS NOT NULL
      AND apply_date IS NOT NULL
      AND status IS NOT NULL
    GROUP BY learner_id
)
SELECT
    o.opportunity_name,
    o.category,
    oa.learner_assignments,
    oa.cohort_count
FROM opportunity_activity oa
JOIN "DVA"."Opportunity_Data" o
  ON oa.opportunity_id = o.opportunity_id
ORDER BY oa.cohort_count DESC, oa.learner_assignments DESC
LIMIT 10;

-- 4. Count enrolled and not-enrolled learners with usable profile details.
WITH profiled_learners AS (
    SELECT learner_id
    FROM "DVA"."User Data"
    WHERE degree IS NOT NULL
      AND institution IS NOT NULL
      AND major IS NOT NULL
),
enrolled_learners AS (
    SELECT DISTINCT enrollment_id AS learner_id
    FROM "DVA"."Learner_Opportunity_Data"
    WHERE assigned_cohort IS NOT NULL
      AND apply_date IS NOT NULL
      AND status IS NOT NULL
)
SELECT
    COUNT(*) AS profiled_learners,
    COUNT(*) FILTER (WHERE e.learner_id IS NOT NULL) AS enrolled_learners,
    COUNT(*) FILTER (WHERE e.learner_id IS NULL) AS not_enrolled_learners
FROM profiled_learners p
LEFT JOIN enrolled_learners e USING (learner_id);
