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

/*select*
from 
GENERATE_SERIES(TIMESTAMP '2022-10-26', TIMESTAMP '2022-11-15', INTERVAL '1 DAY') AS scaffold(day)*/

/*select day, hadm_id
from q0 INNER JOIN yl_admissions AS adm
ON q0.day BETWEEN adm.admittime AND adm.dischtime*/

/*select*
from mh_inputevents
Limit 20*/

/*Create Table yl_inputevents AS
select *
From inputevents;

CREATE Table yl_d_items AS
select *
From d_items;

CREATE Table yl_dlabitems AS
select *
From d_labitems;

CREATE Table yl_labevents AS
select *
From labevents;*/
Drop table yl_Antibiotic_Cr;
Create table yl_Antibiotic_Cr AS
WITH q0 as
(select 
GENERATE_SERIES(MIN(admittime), MAX(dischtime),INTERVAL '1 DAY') AS day
from yl_admissions)
, q1 AS
(SELECT hadm_id, day::DATE
FROM q0 INNER JOIN yl_admissions as adm ON q0.day BETWEEN adm.admittime::DATE AND adm.dischtime::date)

, q2 AS
(SELECT hadm_id, item.abbreviation, starttime::DATE, endtime::DATE
from yl_d_items AS item
INNER JOIN yl_inputevents AS inp ON item.itemid = inp.itemid
WHERE (label like '%anco'
OR label like '%iperacillin%'
OR label like '%ertapenam%'
OR label like '%levofloxacin%'
OR label like '%cefepime%')
AND category = 'Antibiotics')

,q3 AS
(SELECT abbreviation, q1.*
FROM q1 LEFT JOIN q2 ON q1.hadm_id = q2.hadm_id AND
q1.day BETWEEN starttime::date and endtime::date)

,q4 AS
(SELECT hadm_id, day,
SUM(CASE WHEN abbreviation = 'Vancomycin' THEN 1 else 0 end) AS Vanc,
SUM(CASE WHEN abbreviation LIKE '%Zosyn%' THEN 1 ELSE 0 END) AS Zosyn,
SUM(CASE WHEN abbreviation Not LIKE '%Zosyn%' AND abbreviation
	!= 'Vancomycin' THEN 1 else 0 end) AS Other
from q3
group by hadm_id, day)

,q5 AS (SELECT
      AVG(cast(value AS numeric))  
	      OVER(Partition By hadm_id, charttime::date) AS AverageCr,
      first_value(cast(value AS numeric))
		   OVER(Partition by hadm_id, charttime::date order by charttime Desc) AS LastCr,
       hadm_id,
       charttime,
	   cast(value AS numeric) AS value,
	   row_number()	OVER (Partition by hadm_id, charttime::date order by charttime),
	   flag
     
FROM yl_dlabitems AS items
INNER JOIN yl_labevents AS lab
ON items.itemid = lab.itemid
WHERE label LIKE '%reatinine%'
AND fluid = 'Blood'
	  ORDER BY hadm_id,charttime)
	  
, q6 AS
(SELECT 
 avg(value) AS AverageCr,
 max(value) AS MaxCr,
 max(LastCr) AS LastCr,
 hadm_id,
 charttime::date AS charttime,
 sum(CASE WHEN flag is not null THEN 1 ELSE 0 END) AS AlnormalCount	 
 From q5
group by hadm_id, charttime::date)

SELECT q4.*, AverageCr, MaxCr, alnormalCount,
CASE 
WHEN vanc >0 AND zosyn >0 THEN 'Vanc&Zosyn'
WHEN vanc >0 AND zosyn >0 THEN 'Vanc&Other'
WHEN vanc >0 THEN 'Vanc'
WHEN zosyn>0 OR other >0 THEN 'Other'
WHEN vanc+zosyn+other=0 THEN 'None'
ELSE 'Underfined' END as Antibiotic 
FROM q4

LEFT JOIN q6 ON q4.hadm_id=cast(q6.hadm_id AS bigint)
		   AND q4.day=q6.charttime
		 

 




