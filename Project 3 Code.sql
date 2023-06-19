CREATE DATABASE case_study1;
USE case_study1;

CREATE TABLE job_data (
    ds DATE,
    job_id INT,
    actor_id INT,
    job_event VARCHAR(20),
    job_language VARCHAR(20),
    time_spent INT,
    org VARCHAR(10)
);

INSERT INTO job_data 
VALUES ('2020-11-30',21,1001,'skip','English',15,'A'),
('2020-11-30',22,1006,'transfer','Arabic',25,'B'),
('2020-11-29',23,1003,'decision','Persian',20,'C'),
('2020-11-28',23,1005,'transfer','Persian',22,'D'),
('2020-11-28',25,1002,'decision','Hindi',11,'B'),
('2020-11-27',11,1007,'decision','French',104,'D'),
('2020-11-26',23,1004,'skip','Persian',56,'A'),
('2020-11-25',20,1003,'transfer','Italian',45,'C');


 -- Number of jobs reviewed
 #1 Distinct Jobs reviewed
 SELECT 
    COUNT(DISTINCT job_id)/(30*24) AS `Distinct Jobs Reviewed Per Day Per Hour`
FROM
    job_data;
    
#2 Total Jobs reviewed (non-distinct)
 SELECT 
    COUNT( job_id)/(30*24) AS `Jobs Reviewed Per Day Per Hour`
FROM
    job_data;


-- Throughput
# DISCTINCT JOBS
SELECT 
	ds AS date_of_review,
    jobs_reviewed,
    AVG(jobs_reviewed)
OVER 
	(ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS `Throughput 7 day Rolling Average` 
FROM 
	(SELECT ds, count(distinct job_id) AS jobs_reviewed FROM job_data GROUP BY ds ORDER BY ds)a;

# NON_DISTINCT JOBS
SELECT 
	ds AS date_of_review,
	jobs_reviewed,
	AVG(jobs_reviewed)
OVER 
	(ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS `Throughput 7 day Rolling Average(Non-Distinct Jobs)` 
FROM 
	(SELECT ds, count( job_id) AS jobs_reviewed FROM job_data GROUP BY ds ORDER BY ds)a;
    
-- Percentage share of each language
SELECT 
	jd.job_id,
	jd.job_language, 
	COUNT(jd.job_language) AS `Total Languages`, 
	ROUND(((COUNT(jd.job_language)
    /
    (SELECT COUNT(*) FROM job_data))*100),2)
    AS `Percentage Share of each Language`
FROM 
	job_data jd
GROUP BY
	jd.job_language;

-- Duplicate Rows
SELECT 
	* 
FROM 
(	SELECT 
	*,
    ROW_NUMBER()OVER(PARTITION BY job_id) AS row_num 
	FROM job_data
    ) a 
	WHERE row_num>1;
    
    
/* INVESTIGATING METRIC SPIKE */
    
-- User Engagement
    SELECT 
    EXTRACT(WEEK FROM occurred_at) AS `Week Number`,
    COUNT(DISTINCT user_id) AS `Number of Users Engaged`
FROM
    `events`
GROUP BY  `Week Number`;

-- User Growth
SELECT
`Year`,
`Week`,
`Number of Active Users`,
SUM(`Number of Active Users`)OVER(ORDER BY `Year`, `Week` ROWS BETWEEN
UNBOUNDED PRECEDING AND CURRENT ROW) AS `Cum-Number of Active Users`
FROM
(
SELECT 
extract(YEAR FROM a.activated_at) AS`Year`,
extract(WEEK FROM a.activated_at) AS `Week`,
count(DISTINCT user_id) as`Number of Active Users`
FROM users a 
WHERE state = 'active'
GROUP BY `Year`, `Week`
ORDER BY `Year` , `Week`
)a;

SELECT 
    COUNT(*)
FROM
    users
WHERE
    state = 'active';
/*-  --------------------------------*/
    
--  Weekly Retention    
SELECT DISTINCT
    user_id,
    COUNT(user_id),
    SUM(CASE
        WHEN retention_week = 1 THEN 1
        ELSE 0
    END) as `Per Week Retention` 
FROM 
(
SELECT 
	a.user_id, 
    a.signup_week,
    b.engagement_week,
    b.engagement_week - a.signup_week AS retention_week
    FROM
    ( 
    (
    SELECT DISTINCT 
    user_id, 
    EXTRACT(WEEK FROM occurred_at) AS signup_week
    FROM 
		`events` 
    WHERE 
		event_type = 'signup_flow' AND event_name = 'complete_signup'
        )a
	LEFT JOIN 
    (SELECT 
		DISTINCT user_id,
        EXTRACT(WEEK FROM occurred_at) as engagement_week 
	FROM
		`events`
        )b
	on a.user_id = b.user_id
    )
    )d
    GROUP BY user_id
    ORDER BY user_id;


-- Weekly Engagement
SELECT 
  extract(year from occurred_at) as year_num,
  extract(week from occurred_at) as week_num,
  device,
  COUNT(distinct user_id) as no_of_users
FROM 
  `events`
where event_type = 'engagement'
GROUP by 1,2,3
order by 1,2,3;

-- Email Engagement

SELECT
  100*SUM(CASE when email_cat = 'email_opened' then 1 else 0 end)/SUM(CASE when email_cat = 'email_sent' then 1 else 0 end) as email_opening_rate,
  100*SUM(CASE when email_cat = 'email_clicked' then 1 else 0 end)/SUM(CASE when email_cat = 'email_sent' then 1 else 0 end) as email_clicking_rate
FROM 
(
SELECT 
  *,
  CASE 
    WHEN action in ('sent_weekly_digest','sent_reengagement_email')
      then 'email_sent'
    WHEN action in ('email_open')
      then 'email_opened'
    WHEN action in ('email_clickthrough')
      then 'email_clicked'
  end as email_cat
from email_events
) a;