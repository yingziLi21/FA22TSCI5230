/*create table YL_patients as select * from patients;
create table YL_admissions as select * from admissions;
create table YL_transfers as select * from transfers;*/

/*CREATE TABLE YL_demographics as
SELECT
  subject_id,
  COUNT(DISTINCT ethnicity) as ethnicity_demo,
  cast(array_agg(ethnicity) as character(20)) as ethnicity_combo,
  MAX(language) as language_demo,
  MAX(deathtime) as death,
  COUNT(*) as admits,
  COUNT(edregtime) as num_ED,
  avg(DATE_PART('day', dischtime - admittime)) as LOS
FROM YL_admissions GROUP BY subject_id


CREATE TABLE YL_demographics1 AS
SELECT demo.*, pt.gender, anchor_age, anchor_year, anchor_year_group
FROM YL_demographics AS demo
LEFT JOIN YL_patients AS pt
ON demo.subject_id = pt.subject_id*/

-- table
/*SELECT COUNT (*),language_demo
FROM yl_demographics
GROUP BY language_demo

-- setdiff(Demographics$subject_id, patients$subject_id)
SELECT subject_id FROM yl_demographics
EXCEPT
SELECT subject_id FROM yl_demographics*/







