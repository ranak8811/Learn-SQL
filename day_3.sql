use Practice_SQL;

create table hospital ( emp_id int
, action varchar(10)
, time datetime);

insert into hospital values ('1', 'in', '2019-12-22 09:00:00');
insert into hospital values ('1', 'out', '2019-12-22 09:15:00');
insert into hospital values ('2', 'in', '2019-12-22 09:00:00');
insert into hospital values ('2', 'out', '2019-12-22 09:15:00');
insert into hospital values ('2', 'in', '2019-12-22 09:30:00');
insert into hospital values ('3', 'out', '2019-12-22 09:00:00');
insert into hospital values ('3', 'in', '2019-12-22 09:15:00');
insert into hospital values ('3', 'out', '2019-12-22 09:30:00');
insert into hospital values ('3', 'in', '2019-12-22 09:45:00');
insert into hospital values ('4', 'in', '2019-12-22 09:45:00');
insert into hospital values ('5', 'out', '2019-12-22 09:40:00');


-- we need to find number of employees inside the hospital

-- using cte --> method 1
WITH cte AS
(SELECT 
    emp_id,
    MAX(CASE
        WHEN action = 'in' THEN time
    END) AS intime,
    MAX(CASE
        WHEN action = 'out' THEN time
    END) AS outtime
FROM
    hospital
GROUP BY emp_id
HAVING MAX(CASE
        WHEN action = 'in' THEN time
    END) > MAX(CASE
        WHEN action = 'out' THEN time
    END) OR MAX(CASE
        WHEN action = 'out' THEN time
    END) IS NULL
)

SELECT * from cte where intime > outtime or outtime is null;




-- method 2
with intime as (
select emp_id, max(time) as latest_in_time
from hospital
where action = 'in'
group by emp_id),

outtime as
(
select emp_id, max(time) as latest_out_time
from hospital
where action = 'out'
group by emp_id)

select * from intime
left join outtime on intime.emp_id = outtime.emp_id
where latest_in_time > latest_out_time or latest_out_time is null;


-- method 3
with latest_time as (
select emp_id, max(time) as max_latest_time from hospital GROUP BY emp_id
),
latest_in_time as (select emp_id, max(time) as max_in_time from hospital 
where action = 'in'
GROUP BY emp_id)

select * from latest_time lt 
inner join latest_in_time lit on lt.emp_id = lit.emp_id
and max_latest_time = max_in_time;


-- collected from comments
WITH CTE AS (
SELECT emp_id, action,
ROW_NUMBER() OVER (PARTITION BY emp_id ORDER BY time DESC  ) AS IO
FROM hospital)

SELECT emp_id
FROM CTE 
WHERE IO =1 AND Action ='IN';

-- 

with cte as (
select *,case when action = 'out' then 0
when action = 'in' then 1 end as total,
row_number() over(partition by emp_id order by time desc) as rnk from hospital)

select * from cte 
where rnk=1 and total =1;
-- select sum(total) from cte where rnk=1;

--

select emp_id from 
(select emp_id, action, time,
dense_rank() over (partition by emp_id order by time desc) row_num from hospital) A 
where A.row_num=1 and A.action="in";