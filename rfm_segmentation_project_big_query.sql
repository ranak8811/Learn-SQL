SELECT * FROM `sql-learning-461106.ecommerce_dataset.rfm-data` LIMIT 10;

SELECT 
  count(*) total_order_line_item, -- 2,823
  count(distinct ORDERNUMBER) as total_orders -- 307
FROM `sql-learning-461106.ecommerce_dataset.rfm-data`;

SELECT 
  YEAR_ID,
  count(distinct ORDERNUMBER) as total_orders -- 307
FROM `sql-learning-461106.ecommerce_dataset.rfm-data`
group by YEAR_ID
order by YEAR_ID;


SELECT 
  extract (YEAR FROM ORDERDATE) as YEAR,
  count(distinct ORDERNUMBER) as total_orders -- 307
FROM `sql-learning-461106.ecommerce_dataset.rfm-data`
group by 1
order by 1;

SELECT 
  CUSTOMERNAME,
  max(ORDERDATE) as last_order_date,
  count(distinct ORDERNUMBER) as frequency_value,
  round(sum(SALES), 0) as monetory_value
FROM `sql-learning-461106.ecommerce_dataset.rfm-data`
group by 1;


select * from `sql-learning-461106.ecommerce_dataset.rfm-data` where SALES <= 0 and QUANTITYORDERED <= 0; -- no anomalies

select current_date();

select max(ORDERDATE) from `sql-learning-461106.ecommerce_dataset.rfm-data`; -- 2005-05-31
 
SELECT 
  CUSTOMERNAME,
  max(ORDERDATE) as last_order_date,
  date_diff((select max(ORDERDATE) from `sql-learning-461106.ecommerce_dataset.rfm-data`), max(ORDERDATE), DAY) as recency_value_in_days,
  count(distinct ORDERNUMBER) as frequency_value,
  round(sum(SALES), 0) as monetory_value
FROM `sql-learning-461106.ecommerce_dataset.rfm-data`
group by 1;


-- RFM Segmentation

create view `sql-learning-461106.ecommerce_dataset.rfm-segmentation-data` as

with rfm_values as (
SELECT 
  CUSTOMERNAME,
  date_diff((select max(ORDERDATE) from `sql-learning-461106.ecommerce_dataset.rfm-data`), max(ORDERDATE), DAY) as recency_value_in_days,
  count(distinct ORDERNUMBER) as frequency_value,
  round(sum(SALES), 0) as monetory_value
FROM `sql-learning-461106.ecommerce_dataset.rfm-data`
group by 1
),

 rfm_score as (
select
  rv.*,
  ntile(5) over (order by recency_value_in_days desc) as r_score,
  ntile(5) over (order by frequency_value asc) as f_score,
  ntile(5) over (order by monetory_value asc) as m_score
from rfm_values rv
 ),

rfm_combination_cte as (
select 
  CUSTOMERNAME,
  recency_value_in_days, r_score,
  frequency_value, f_score,
  monetory_value, m_score,
  (m_score + f_score + r_score) as total_rfm_score,
  concat(m_score , f_score , r_score) as rfm_combination
from rfm_score as rs
)

select 
  rc_cte.*,
  CASE
    WHEN rfm_combination IN ('455', '542', '544', '552', '553', '452', '545', '554', '555') THEN 'Champions'
    WHEN rfm_combination IN ('344', '345', '353', '354', '355', '443', '451', '342', '351', '352', '441', '442', '444', '445', '453', '454', '541', '543', '515', '551') THEN 'Loyal Customers'
    WHEN rfm_combination IN ('513', '413', '511', '411', '512', '341', '412', '343', '514') THEN 'Potential Loyalists'
    WHEN rfm_combination IN ('414', '415', '214', '211', '212', '213', '241', '251', '312', '314', '311', '313', '315', '243', '245', '252', '253', '255', '242', '244', '254') THEN 'Promising Customers'
    WHEN rfm_combination IN ('141', '142', '143', '144', '151', '152', '155', '145', '153', '154', '215') THEN 'Needs Attention'
    WHEN rfm_combination IN ('113', '111', '112', '114', '115') THEN 'About to Sleep'
    ELSE 'OTHER'
    end as customer_segment
from rfm_combination_cte rc_cte;

-- to show the view that has been created above

SELECT * FROM `sql-learning-461106.ecommerce_dataset.rfm-segmentation-data` ;

select
  customer_segment,
  count(*) as number_of_customer,
  round(avg(recency_value_in_days), 1) as average_days_of_last_activity,
  sum(frequency_value) as total_oreders,
  round(avg(frequency_value), 1) as average_number_of_oreders,

  round(sum(monetory_value), 0) as total_oreder_value,
  round(avg(monetory_value), 1) as average_oreder_value,

from `sql-learning-461106.ecommerce_dataset.rfm-segmentation-data`
group by customer_segment;