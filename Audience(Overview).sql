
/* Confirmation required with unsampled report */ 
 
SELECT
   -- 1. User
   COUNT(DISTINCT(fullVisitorId)) AS Users, 
   -- 2. New Visitor
   COUNTIF(totals.newVisits = 1) AS New_Visitors,
   -- 3. Session
   SUM(totals.visits) AS Sessions, -- COUNT(DISTINCT(CONCAT(fullVisitorId, visitId, visitStartTime))) AS SESSION2, -- AND totals.visits = 1  
   -- 4. Sessions per user
   ROUND(SUM(totals.visits) / COUNT(DISTINCT(fullVisitorId)), 2) AS Sessions_Per_User,
   -- 5. Pageviews
   SUM(totals.pageviews) AS Pageviews,
   -- 6. Pages per session
   ROUND(SUM(totals.pageviews) / SUM(totals.visits), 2) AS Pages_Per_Session,
   -- 7. Average session time
   ROUND(SUM(totals.timeonsite)/ SUM(totals.visits)) AS Avg_Session_Duration,
   -- 8. Bounce Rate
   ROUND(SUM(totals.bounces) / SUM(totals.visits) * 100, 2) AS Bounce_Rate

FROM `table_name`
WHERE 1=1
  AND _TABLE_SUFFIX BETWEEN '20210101' AND '20211231'