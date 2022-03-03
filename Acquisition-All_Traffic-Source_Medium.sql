/* Confirmation required with unsampled report */ 

-- Sum
WITH SUM AS (
  SELECT 
  COUNT(DISTINCT fullvisitorid) AS Users,
  SUM(CASE WHEN totals.newVisits = 1 THEN 1 ELSE 0 END) AS New_Visitors, 
  COUNTIF(totals.visits = 1) AS Sessions, 
  ROUND(SUM(totals.bounces) / SUM(totals.visits) * 100, 2) AS Bounce_Rate, 
  ROUND(SUM(totals.pageviews) / SUM(totals.visits), 2) AS Pages_Per_Session,
  ROUND(SUM(totals.timeonsite)/ SUM(totals.visits)) AS Avg_Session_Duration,
  FROM
    `table name`
  WHERE 1=1
    AND _TABLE_SUFFIX BETWEEN '20210101' AND '20211231' 
)

, SEPAR AS(
  select
    Source_Medium, 
    COUNT(DISTINCT fullvisitorid) AS Users,
    SUM(user_type) AS New_Visitors, 
    SUM(totalvisit) AS Sessions, 
    ROUND(COUNT(DISTINCT CASE WHEN bounce = 1 THEN sid ELSE NULL END) / COUNT(DISTINCT sid) * 100, 2) AS Bounce_Rate,
    ROUND(SUM(pageview) / COUNT(DISTINCT sid), 2) AS Pages_Per_Session,
    ROUND(IFNULL(SUM(timeonsite) / COUNT(DISTINCT sid), 0) , 0) AS Avg_Session_Duration,
  from
  (SELECT
    CONCAT(trafficsource.source," / ",trafficsource.medium) AS Source_Medium,
    fullvisitorid,
    visitid,
    CASE WHEN totals.newVisits = 1 THEN 1 ELSE 0 END AS user_type,
    totals.visits AS totalvisit, --  concat(fullvisitorid, visitid, visitstarttime) AS sid
    totals.bounces AS bounce,
    CONCAT(fullvisitorid, visitid, visitstarttime) AS sid,
    totals.pageviews AS pageview,
    totals.timeonsite AS timeonsite
  FROM
    `table name`
  WHERE 1=1
    AND _TABLE_SUFFIX BETWEEN '20210101' AND '20211231' 
    AND totals.visits = 1
  )
  group by 1
  order by 2 desc
)

SELECT * FROM SUM
-- SELECT * FROM SEPAR
