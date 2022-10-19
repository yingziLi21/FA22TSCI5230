-- !preview conn=DBI::dbConnect(RPostgres::Postgres(),dbname = 'postgres', host = 'db.zgqkukklhncxcctlqpvg.supabase.co', port = 5432, user = 'student',password = '')

/*SELECT *
FROM  YL_patients
limit 10*/

SELECT
        subject_id, -- admittime, dischtime, ethnicity,
        COUNT(DISTINCT ethnicity) as ethnicity_demo,
        array_agg(ethnicity) as ethnicity_combo,
        MAX (language) as language_demo,
        MAX (deathtime) as death,
        COUNT(*) as admits,
        COUNT(edregtime) as num_ED,
        AVG (DATE_PART('day', dischtime - admittime)) as los

 -- language, deathtime, edregtime
FROM mh_admissions GROUP BY subject_id
limit 10

SELECT COUNT (*)
FROM sl_demographics
GROUP BY lanuage_demo
-- table(admissions$language)



