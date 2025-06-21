use Practice_SQL;

create table tickets
(
ticket_id varchar(10),
create_date date,
resolved_date date
);
delete from tickets;
insert into tickets values
(1,'2022-08-01','2022-08-03')
,(2,'2022-08-01','2022-08-12')
,(3,'2022-08-01','2022-08-16');
create table holidays
(
holiday_date date
,reason varchar(100)
);
delete from holidays;
insert into holidays values
('2022-08-11','Rakhi'),('2022-08-15','Independence day');


-- we need to find difference between 2 dates excluding weekends and public holidays  .
-- Basically we need to find business days between 2 given dates using SQL.

SELECT 
    *, 
    DATEDIFF(resolved_date, create_date) AS actual_days,
    WEEK(create_date) AS create_week,
    WEEK(resolved_date) AS resolved_week,
    FLOOR(DATEDIFF(resolved_date, create_date) / 7) AS actual_weeks
FROM
    tickets;


SELECT 
    *, 
    DATEDIFF(resolved_date, create_date) AS actual_days,
	DATEDIFF(resolved_date, create_date) - (2 * FLOOR(DATEDIFF(resolved_date, create_date) / 7)) AS business_days
FROM
    tickets;
    
select * from holidays;


SELECT 
    *,
    DATEDIFF(resolved_date, create_date) AS actual_days,
    DATEDIFF(resolved_date, create_date) - (2 * FLOOR(DATEDIFF(resolved_date, create_date) / 7)) - no_of_holidays AS business_days
FROM
    (SELECT 
        ticket_id,
            create_date,
            resolved_date,
            COUNT(holiday_date) AS no_of_holidays
    FROM
        tickets
    LEFT JOIN holidays ON holiday_date BETWEEN create_date AND resolved_date
    GROUP BY ticket_id , create_date , resolved_date) as for_later;

-- more organized code
SELECT
    s.ticket_id,
    s.create_date,
    s.resolved_date,
    s.no_of_holidays,
    -- total calendar days
    DATEDIFF(s.resolved_date, s.create_date) AS actual_days,
    -- business-day calculation: days – full weekends – holidays
    DATEDIFF(s.resolved_date, s.create_date)
      - (2 * FLOOR(DATEDIFF(s.resolved_date, s.create_date) / 7))
      - s.no_of_holidays                       AS business_days
FROM (
    SELECT
        t.ticket_id,
        t.create_date,
        t.resolved_date,
        COUNT(h.holiday_date) AS no_of_holidays      -- counts only non-NULL holiday rows
    FROM tickets AS t
    LEFT JOIN holidays AS h
           ON h.holiday_date BETWEEN t.create_date AND t.resolved_date
    GROUP BY t.ticket_id, t.create_date, t.resolved_date
) AS s;            -- ← REQUIRED alias for the derived table



-- Avoid subtracting a holiday that already falls on a weekend (i.e., don't double-count)

insert into holidays values ('2022-08-14', 'Random Weekend Holiday');

SELECT
    s.ticket_id,
    s.create_date,
    s.resolved_date,
    s.no_of_holidays,
    DATEDIFF(s.resolved_date, s.create_date) AS actual_days,
    DATEDIFF(s.resolved_date, s.create_date)
      - (2 * FLOOR(DATEDIFF(s.resolved_date, s.create_date) / 7))
      - s.no_of_holidays AS business_days
FROM (
    SELECT
        t.ticket_id,
        t.create_date,
        t.resolved_date,
        COUNT(h.holiday_date) AS no_of_holidays
    FROM tickets AS t
    LEFT JOIN holidays AS h
        ON h.holiday_date BETWEEN t.create_date AND t.resolved_date
        AND DAYOFWEEK(h.holiday_date) BETWEEN 2 AND 6  -- only count Monday–Friday
    GROUP BY t.ticket_id, t.create_date, t.resolved_date
) AS s;


-- corner case problem found in the comment secetion

-- There is a corner case with the above code - this solution would work only when tickets are created on weekdays and not weekends. 
-- Ideally, as per business case, we should not have a ticket created on weekend but (we all know the kind of data we get is never 100% clean)

-- for current scenario Below 2 scenarios will give incorrect results

-- (4,'2022-08-19','2022-08-27')
-- (5,'2022-08-21','2022-08-27')

insert into tickets values
	(4,'2022-08-19','2022-08-27'),
    (5,'2022-08-21','2022-08-27');
    
-- solved from comment section
-- ❶ Generate every calendar day for each ticket
WITH RECURSIVE date_span AS (                       -- anchor row
     SELECT
         t.ticket_id,
         t.create_date       AS span_date,
         t.resolved_date
     FROM tickets AS t

     UNION ALL                                         -- recursive step
     SELECT
         ds.ticket_id,
         DATE_ADD(ds.span_date, INTERVAL 1 DAY),       -- next day
         ds.resolved_date
     FROM date_span AS ds
     WHERE ds.span_date < ds.resolved_date             -- stop when we reach the end date
),

-- ❷ Mark weekends and company holidays
calendar_flags AS (
    SELECT
        ds.ticket_id,
        ds.span_date,
        /* Weekend?  DAYOFWEEK(): 1 = Sun, …, 7 = Sat  */
        CASE WHEN DAYOFWEEK(ds.span_date) IN (1,7) THEN 1 ELSE 0 END AS is_weekend,
        /* Holiday?  LEFT JOIN → NULL if not a holiday */
        CASE WHEN h.holiday_date IS NOT NULL           THEN 1 ELSE 0 END AS is_holiday
    FROM date_span AS ds
    LEFT JOIN holidays AS h
           ON h.holiday_date = ds.span_date
)

-- ❸ Aggregate per ticket
SELECT
    ticket_id,
    MIN(span_date)                              AS start_date,
    MAX(span_date)                              AS end_date,
    COUNT(*)                                    AS total_calendar_days,
    SUM(is_weekend)                             AS weekend_days,
    SUM(is_holiday)                             AS holiday_weekdays,
    COUNT(*) - SUM(is_weekend) - SUM(is_holiday) AS business_days
FROM calendar_flags
GROUP BY ticket_id
ORDER BY ticket_id;
