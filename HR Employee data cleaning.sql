CREATE DATABASE HR;

USE hr;

SELECT * from hr;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

SELECT * from hr;

DESCRIBE hr;

SELECT birthdate from hr;

SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
	WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
	ELSE null
END;    

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
	WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
	ELSE null
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !='';
SELECT termdate from hr;

UPDATE hr
SET termdate = NULL
WHERE  termdate ='';

UPDATE hr
SET termdate = NULL
WHERE  termdate ='0000-00-00';
SELECT termdate from hr;

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

ALTER TABLE hr
ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, curdate());

SELECT age, birthdate from hr;

SELECT MIN(age) As youngest,
max(age) As oldest
from hr;

select * from hr ;



-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?--

SELECT gender, count(*) as count_
from hr
where age > 18 and termdate is null
group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, count(*) as count_
from hr
where age > 18 and termdate is null
group by race
order by count_ desc;
-- 3. What is the age distribution of employees in the company?
SELECT MIN(age) As youngest,
max(age) As oldest
from hr
where age > 18 and termdate is null;

Select 
case when age >=18 and age <=24 then '18-24'
 when age >=25 and age <=34 then '25-34'
 when age >=35 and age <=44 then '35-44'
 when age >=45 and age <=54 then '45-54'
 when age >=55 and age <=64 then '55-64'
else '65+' end as age_group, 
count(*) as count_
from hr
where age > 18 and termdate is null
group by age_group
order by age_group;

-- 4. How many employees work at headquarters versus remote locations?
select location, count(*) as count_
from hr
where age >= 18 and termdate is null
group by location;

-- 5. What is the average length of employment for employees who have been terminated?
select 
round(avg(datediff(termdate, hire_date))/365,0) as avg_emp_len
from hr
where termdate <= curdate() and age >= 18 and termdate is not null;
-- 6. How does the gender distribution vary across departments and job titles?
select gender, department, count(*) as count_
from hr
where age >= 18 and termdate is null
group by department, gender
order by department;

-- 7. What is the distribution of job titles across the company?
select jobtitle, count(*) as count_
from hr
where age >= 18 and termdate is null
group by jobtitle
order by jobtitle desc;

-- 8. Which department has the highest turnover rate?
select department, total_count, termination_count, termination_count/total_count as termination_rate
from
(select department, count(*) as total_count,
sum(case when termdate is not null and termdate <= curdate() then 1 else 0 end ) as termination_count
from hr
where age >= 18
group by department) as sub
order by termination_rate desc;
-- 9. What is the distribution of employees across locations by city and state?
select location_state, count(*) as count_
from hr
where age >= 18 and termdate is  null
group by location_state
order by count_ desc ;
-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT year_, 
hires,
terminations, 
hires-terminations AS net_change, 
round((hires-terminations)/hires*100, 2) as net_change_percent
from(
select year(hire_date) as year_, 
count(*) as hires,
sum(case when termdate is not null and termdate <=curdate() then 1 else 0 end) as terminations
from hr
where age >= 18
group by year(hire_date)
) as sub
order by year_;
-- 11. What is the tenure distribution for each department?
select department,
round(avg(datediff(termdate, hire_date)/365),0) as avg_tenure
from hr
where termdate is not null and termdate<=curdate() and age>=18
group by department;


