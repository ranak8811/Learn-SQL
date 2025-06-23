use Practice_SQL;

create table airbnb_searches 
(
user_id int,
date_searched date,
filter_room_types varchar(200)
);
delete from airbnb_searches;
insert into airbnb_searches values
(1,'2022-01-01','entire home,private room')
,(2,'2022-01-02','entire home,shared room')
,(3,'2022-01-02','private room,shared room')
,(4,'2022-01-03','private room')
;


/*Find the room types that are searched most no of times.
Output the room type alongside the number of searches for it.
If the filter for room types has more than one room type, 
consider each unique room type as a separate row.
Sort the result based on the number of searches in descending order.
*/

SELECT * from airbnb_searches;

-- string split

WITH RECURSIVE split_string AS (
    SELECT 
        SUBSTRING_INDEX('entire home,private room', ',', 1) AS value,
        SUBSTRING('entire home,private room', LENGTH(SUBSTRING_INDEX('entire home,private room', ',', 1)) + 2) AS remaining
    UNION ALL
    SELECT 
        SUBSTRING_INDEX(remaining, ',', 1),
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_string
    WHERE remaining != ''
)
SELECT value FROM split_string;


-- solution below


WITH RECURSIVE split_room_types AS (
  -- Anchor member: get first room type per row
  SELECT
    user_id,
    TRIM(SUBSTRING_INDEX(filter_room_types, ',', 1)) AS room_type,
    SUBSTRING(filter_room_types, LENGTH(SUBSTRING_INDEX(filter_room_types, ',', 1)) + 2) AS remaining
  FROM airbnb_searches

  UNION ALL

  -- Recursive member: process remaining string
  SELECT
    user_id,
    TRIM(SUBSTRING_INDEX(remaining, ',', 1)),
    SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
  FROM split_room_types
  WHERE remaining != ''
)

SELECT
  room_type,
  COUNT(*) AS no_of_searches
FROM split_room_types
GROUP BY room_type
ORDER BY no_of_searches DESC;

-- solutions from comment section

with cte as (
	select sum(case when filter_room_types like '%entire%' then 1 else 0 end ) as entire,
	sum(case when filter_room_types like '%private%' then 1 else 0 end ) as private,
	sum(case when filter_room_types like '%shared%' then 1 else 0 end ) as shared
from airbnb_searches)
	select 'entire room' as value , entire as count from cte
	union all
	select 'private room' as value , private as count from cte
	union all 
	select 'shared room' as value , shared as count from cte
	order by count desc;
    
    
-- 

with cte as
	(select *,substring_index(filter_room_types,',',1) as Search_1 from airbnb_searches
	union 
	select *,substring_index(filter_room_types,',',-1) as Search_2 from airbnb_searches)
	select Search_1 as 'Room_Type', count(Search_1) as Count from cte 
	group by Search_1 order by Count desc ;
