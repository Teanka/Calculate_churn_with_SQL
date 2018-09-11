-- QUERY 1: Get familiar with the data. How many segments exist?

SELECT * FROM subscriptions
	 LIMIT 100;
	 
/*only 2 segments: 30 and 87.

QUERY 2: Determine the range of months of data provided. 
Which months will you be able to calculate churn for?
First, find out the subscription start: */

SELECT MIN(subscription_start) 
     FROM subscriptions;
 
--And then find out the subscription end date:

--QUERY 3

SELECT MAX(subscription_start) 
    FROM subscriptions;
	
--QUERY 4: What is the overall churn trend since the company started?

WITH months AS 
   (SELECT 
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
    UNION 
    SELECT 
    '2017-02-01' AS first_day,
    '2017-02-28' AS last_day
    UNION
    SELECT
    '2017-03-01' AS first_day,
    '2017-03-31' AS last_day),
 
cross_join AS
    (SELECT * 
        FROM subscriptions
     CROSS JOIN months),
     
  status AS
    (SELECT id, first_day AS month,
  CASE 
   WHEN (subscription_start < first_day)
   AND (subscription_end > first_day
   OR subscription_end IS NULL)
 THEN 1
 ELSE 0 
 END AS is_active,
   CASE 
   WHEN subscription_end BETWEEN first_day AND last_day
 THEN 1
 ELSE 0 
 END AS is_canceled
FROM cross_join),

status_aggregate AS
(SELECT
  month,
  SUM(is_active) as sum_active,
  SUM(is_canceled) as sum_canceled
FROM status
GROUP BY month)

SELECT month, 
 (1.0* status_aggregate.sum_canceled/
 status_aggregate.sum_active) AS general_churn_rate
FROM status_aggregate;

--QUERY 5(the main one):
-- Compare the churn rates between user segments.
--Which segment of users should the company focus on expanding?

WITH months AS 
   (SELECT 
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
    UNION 
    SELECT 
    '2017-02-01' AS first_day,
    '2017-02-28' AS last_day
    UNION
    SELECT
    '2017-03-01' AS first_day,
    '2017-03-31' AS last_day),
 
cross_join AS
    (SELECT * 
        FROM subscriptions
     CROSS JOIN months),

status AS
    (SELECT id, first_day AS month,
  CASE 
   WHEN (subscription_start < first_day)
   AND (subscription_end > first_day
   AND (segment == '87')
   OR subscription_end IS NULL)
   AND (segment == '87')
 THEN 1
 ELSE 0 
 END AS is_active_87,
 CASE 
   WHEN (subscription_start < first_day)
   AND (subscription_end > first_day
   AND (segment == '30')
   OR subscription_end IS NULL)
   AND (segment == '30')
 THEN 1
 ELSE 0 
 END AS is_active_30,
 CASE 
   WHEN subscription_end BETWEEN first_day AND last_day
   AND (segment == '87')
 THEN 1
 ELSE 0 
 END AS is_canceled_87,
 CASE 
   WHEN subscription_end BETWEEN first_day AND last_day
   AND (segment == '30')
 THEN 1
 ELSE 0 
 END AS is_canceled_30
FROM cross_join),

status_aggregate AS
(SELECT
  month,
  SUM(is_active_87) as sum_active_87,
  SUM(is_active_30) as sum_active_30,
  SUM(is_canceled_87) as sum_canceled_87,
  SUM(is_canceled_30) as sum_canceled_30
FROM status
GROUP BY month)

SELECT month, 
 (1.0* status_aggregate.sum_canceled_87/
 status_aggregate.sum_active_87) AS churn_rate_87,
 (1.0* status_aggregate.sum_canceled_30/
 status_aggregate.sum_active_30) AS churn_rate_30
FROM status_aggregate;

