-- Excelerate Learners, Opportunities & Cohorts Analysis
-- Portfolio extract: representative PostgreSQL ETL pipeline
-- The source-system field names are preserved where needed; semantic aliases are used in joins.

CREATE SCHEMA IF NOT EXISTS "DVA_MASTER";

-- -----------------------------------------------------------------------------
-- 1. Clean Cognito/profile data
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "DVA_MASTER"."Cognito_Master" (
    user_id_cleaned TEXT PRIMARY KEY,
    email TEXT,
    gender TEXT,
    state TEXT,
    city TEXT,
    zip TEXT,
    user_create_date DATE,
    user_created_year INT,
    user_created_month INT,
    user_last_modified_date DATE,
    user_modified_year INT,
    user_modified_month INT,
    birthdate DATE,
    birth_year INT
);

INSERT INTO "DVA_MASTER"."Cognito_Master"
SELECT
    'Learner#' || user_id AS user_id_cleaned,
    COALESCE(email, 'Not Mentioned'),
    COALESCE(gender, 'Not Mentioned'),
    COALESCE(state, 'Not Mentioned'),
    COALESCE(city, 'Not Mentioned'),
    COALESCE(zip, 'Not Mentioned'),
    "UserCreateDate"::date,
    EXTRACT(YEAR FROM "UserCreateDate")::int,
    EXTRACT(MONTH FROM "UserCreateDate")::int,
    "UserLastModifiedDate"::date,
    EXTRACT(YEAR FROM "UserLastModifiedDate")::int,
    EXTRACT(MONTH FROM "UserLastModifiedDate")::int,
    birthdate,
    EXTRACT(YEAR FROM birthdate)::int
FROM "DVA"."Cognito_Data";

-- -----------------------------------------------------------------------------
-- 2. Clean learner profile data and derive enrollment status
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "DVA_MASTER"."User_Master" (
    learner_id TEXT PRIMARY KEY,
    country TEXT,
    degree TEXT,
    institution TEXT,
    major TEXT,
    enrollment_status TEXT
);

WITH enrolled_learners AS (
    SELECT DISTINCT enrollment_id AS learner_id
    FROM "DVA"."Learner_Opportunity_Data"
    WHERE enrollment_id IS NOT NULL
      AND enrollment_id <> 'Opportunity#'
),
cleaned_users AS (
    SELECT
        u.learner_id,
        UPPER(COALESCE(u.country, 'Not Mentioned')) AS country,
        UPPER(COALESCE(u.degree, 'Not Mentioned')) AS degree,
        UPPER(COALESCE(u.institution, 'Not Mentioned')) AS institution,
        UPPER(COALESCE(u.major, 'Not Mentioned')) AS major,
        CASE WHEN e.learner_id IS NOT NULL THEN 'Enrolled' ELSE 'Not Enrolled' END AS enrollment_status
    FROM "DVA"."User Data" u
    LEFT JOIN enrolled_learners e
      ON u.learner_id = e.learner_id
)
INSERT INTO "DVA_MASTER"."User_Master"
SELECT * FROM cleaned_users;

-- -----------------------------------------------------------------------------
-- 3. Clean opportunity and cohort dimensions
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "DVA_MASTER"."Opportunity_Master" (
    opportunity_id TEXT PRIMARY KEY,
    opportunity_name TEXT,
    opportunity_category TEXT,
    opportunity_code TEXT
);

INSERT INTO "DVA_MASTER"."Opportunity_Master"
SELECT
    opportunity_id,
    opportunity_name,
    category,
    opportunity_code
FROM "DVA"."Opportunity_Data"
WHERE opportunity_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS "DVA_MASTER"."Cohort_Master" (
    cohort_code TEXT PRIMARY KEY,
    start_date DATE,
    start_year INT,
    start_month INT,
    end_date DATE,
    cohort_span INTERVAL,
    cohort_size INT
);

INSERT INTO "DVA_MASTER"."Cohort_Master"
SELECT
    cohort_code,
    start_date,
    EXTRACT(YEAR FROM start_date)::int,
    EXTRACT(MONTH FROM start_date)::int,
    end_date,
    end_date - start_date,
    size
FROM "DVA"."Cohort_Data"
WHERE cohort_code IS NOT NULL;

-- -----------------------------------------------------------------------------
-- 4. Clean enrollment/activity bridge
-- Important legacy-source note:
--   enrollment_id = learner identifier
--   learner_id    = opportunity identifier
-- The business aliases below remove that ambiguity in the curated model.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "DVA_MASTER"."Learner_Opportunity_Master" (
    learner_id TEXT REFERENCES "DVA_MASTER"."User_Master"(learner_id),
    opportunity_id TEXT REFERENCES "DVA_MASTER"."Opportunity_Master"(opportunity_id),
    assigned_cohort TEXT REFERENCES "DVA_MASTER"."Cohort_Master"(cohort_code),
    apply_date DATE,
    apply_year INT,
    apply_month INT,
    learner_opportunity_status TEXT
);

INSERT INTO "DVA_MASTER"."Learner_Opportunity_Master"
SELECT
    enrollment_id AS learner_id,
    learner_id AS opportunity_id,
    assigned_cohort,
    apply_date::date,
    EXTRACT(YEAR FROM apply_date)::int,
    EXTRACT(MONTH FROM apply_date)::int,
    status::text
FROM "DVA"."Learner_Opportunity_Data"
WHERE assigned_cohort IS NOT NULL
  AND apply_date IS NOT NULL
  AND status IS NOT NULL;

-- -----------------------------------------------------------------------------
-- 5. Analytics-ready view
-- Keeps personally identifying columns out of the portfolio-facing analytical view.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW "DVA_MASTER"."vw_learning_analytics" AS
SELECT
    u.learner_id,
    u.country,
    u.degree,
    u.institution,
    u.major,
    u.enrollment_status,
    lo.opportunity_id,
    o.opportunity_name,
    o.opportunity_category,
    lo.assigned_cohort,
    c.start_date AS cohort_start_date,
    c.end_date AS cohort_end_date,
    c.cohort_size,
    lo.apply_date,
    lo.learner_opportunity_status
FROM "DVA_MASTER"."User_Master" u
LEFT JOIN "DVA_MASTER"."Learner_Opportunity_Master" lo
  ON u.learner_id = lo.learner_id
LEFT JOIN "DVA_MASTER"."Opportunity_Master" o
  ON lo.opportunity_id = o.opportunity_id
LEFT JOIN "DVA_MASTER"."Cohort_Master" c
  ON lo.assigned_cohort = c.cohort_code;
