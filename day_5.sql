use Practice_SQL;

CREATE TABLE emp_salary
(
    emp_id INTEGER  NOT NULL,
    name NVARCHAR(20)  NOT NULL,
	salary NVARCHAR(30),
    dept_id INTEGER
);


INSERT INTO emp_salary
(emp_id, name, salary, dept_id)
VALUES(101, 'sohan', '3000', '11'),
(102, 'rohan', '4000', '12'),
(103, 'mohan', '5000', '13'),
(104, 'cat', '3000', '11'),
(105, 'suresh', '4000', '12'),
(109, 'mahesh', '7000', '12'),
(108, 'kamal', '8000', '11');

-- write a SQL to return all employee whose salary is same in same department

SELECT * FROM Practice_SQL.emp_salary order by dept_id;


-- using inner join

with sal_dep as (
select dept_id, salary from emp_salary
	GROUP BY dept_id, salary
    HAVING count(1) > 1)
    
select * 
from emp_salary es
INNER join sal_dep sd on es.dept_id = sd.dept_id and es.salary = sd.salary;

-- using left join

with sal_dep as (
select dept_id, salary from emp_salary
	GROUP BY dept_id, salary
    HAVING count(1) = 1)
    
select es.* 
from emp_salary es
left join sal_dep sd on es.dept_id = sd.dept_id and es.salary = sd.salary
WHERE sd.dept_id is null;
