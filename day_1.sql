create DATABASE Practice_SQL;

use Practice_SQL;

CREATE TABLE events (
ID int,
event varchar(255),
YEAR INt,
GOLD varchar(255),
SILVER varchar(255),
BRONZE varchar(255)
);

-- delete from events; 

INSERT INTO events VALUES (1,'100m',2016, 'Amthhew Mcgarray','donald','barbara');
INSERT INTO events VALUES (2,'200m',2016, 'Nichole','Alvaro Eaton','janet Smith');
INSERT INTO events VALUES (3,'500m',2016, 'Charles','Nichole','Susana');
INSERT INTO events VALUES (4,'100m',2016, 'Ronald','maria','paula');
INSERT INTO events VALUES (5,'200m',2016, 'Alfred','carol','Steven');
INSERT INTO events VALUES (6,'500m',2016, 'Nichole','Alfred','Brandon');
INSERT INTO events VALUES (7,'100m',2016, 'Charles','Dennis','Susana');
INSERT INTO events VALUES (8,'200m',2016, 'Thomas','Dawn','catherine');
INSERT INTO events VALUES (9,'500m',2016, 'Thomas','Dennis','paula');
INSERT INTO events VALUES (10,'100m',2016, 'Charles','Dennis','Susana');
INSERT INTO events VALUES (11,'200m',2016, 'jessica','Donald','Stefeney');
INSERT INTO events VALUES (12,'500m',2016,'Thomas','Steven','Catherine');


-- we need to find player with no of gold medals won by them only for players who won only gold medals.

SELECT * from events;

SELECT 
    gold AS player_name, COUNT(1) AS no_of_medals
FROM
    events
GROUP BY gold;

-- using sub query method
SELECT 
    gold AS player_name, COUNT(1) AS no_of_medals
FROM
    events
WHERE
    gold NOT IN (SELECT 
            silver
        FROM
            events UNION ALL SELECT 
            bronze
        FROM
            events)
GROUP BY gold;


-- using group by, having and cte method
WITH cte AS (
SELECT 
    gold as player_name, 'gold' AS medal_type
FROM
    events 
UNION ALL SELECT 
    silver, 'silver' AS medal_type
FROM
    events 
UNION ALL SELECT 
    bronze, 'bronze' AS medal_type
FROM
    events)
    
SELECT player_name, count(1) as no_of_gold_medals
from cte
GROUP BY 1
HAVING COUNT(DISTINCT medal_type) = 1 and max(medal_type) = 'gold';