/* Confirmation required with unsampled report */ 

with Only_Bounces as (
select
pagePath as Page,
ROUND(
  CASE
    WHEN sessions = 0 THEN 0
    ELSE bounces / sessions * 100
  END, 2) 
 AS Bounce_Rate
from (
SELECT
  pagePath,
  SUM(bounces) AS bounces,
  SUM(sessions) AS sessions,
FROM (
  SELECT
    pagePath,
    CASE
      WHEN hitNumber = first_interaction THEN bounces
      ELSE 0
    END AS bounces,
    CASE
      WHEN hitNumber = first_hit THEN visits
      ELSE 0
    END AS sessions,
  FROM (
    SELECT
      hits.page.pagePath,
      totals.bounces ,
      totals.visits,
      hits.hitNumber,
      MIN(IF(hits.isInteraction IS NOT NULL, hits.hitNumber, 0)) OVER (PARTITION BY fullVisitorId, visitId, visitStartTime) as first_interaction,
      MIN(hits.hitNumber) OVER (PARTITION BY fullVisitorId, visitId, visitStartTime) as first_hit
    FROM
      `table name` AS GA, UNNEST(GA.hits) AS hits
    WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20211231'))
GROUP BY pagePath
  )
)


select
 t.Page as Page,
 Pageviews_Cnt as Pageviews,
 Unique_Pageviews_Cnt as Unique_Pageviews,
 IF(Avg_Time_On_Page is null, 0, Avg_Time_On_Page) as Avg_Time_On_Page,
 Entrances,
 b.bounce_rate as Exit,
 ROUND( 
  CASE
    WHEN Pageviews_Cnt = 0 THEN 0
    ELSE exits / Pageviews_Cnt * 100
  END, 2) 
 AS Exit_Rate,
from(
select 
  Page,
  COUNT(*) as Pageviews_Cnt,  
  COUNT(DISTINCT concat(sid, COALESCE(page, ''), COALESCE(title, ''))) as Unique_Pageviews_Cnt,
  ROUND(SAFE_DIVIDE(SUM(TimeOnPage),(SUM(PageViews)-Sum(Exits))), 0) as Avg_Time_On_Page,
  COUNT(Entrances) as Entrances,
  SUM(exits) as exits,
from(
SELECT
 sid,
 Entrances,
 Page, 
 Title,
 PageViews,
 CASE WHEN exit =TRUE 
  THEN  LastInteraction-hitTime
  ELSE  LEAD(hitTime) OVER (PARTITION BY sid ORDER BY hitNum) - hitTime
 END as TimeOnPage, 
 Exits,
FROM (
  SELECT
    CONCAT(fullVisitorId, visitId, visitStartTime) as sid,
    hits.Page.pagePath as Page,
    hits.Page.pageTitle as Title,
    hits.isEntrance as Entrances,  
    hits.IsExit as exit,
    CASE WHEN hits.Isexit =TRUE THEN 1 ELSE 0 END as Exits,
    hits.hitNumber as hitNum,
    hits.Type as hitType,
    hits.time/1000 as hitTime,
    CASE
      WHEN type="PAGE" AND totals.visits=1 THEN 1 ELSE 0
    END as PageViews,
    MAX(IF(hits.isInteraction = TRUE, hits.time / 1000, 0)) OVER (PARTITION BY fullVisitorId, visitId, visitStartTime) as LastInteraction,
    MIN(IF(hits.isInteraction IS NOT NULL, hits.hitNumber, 0)) OVER (PARTITION BY fullVisitorId, visitId, visitStartTime) as first_interaction,
    MIN(hits.hitNumber) OVER (PARTITION BY fullVisitorId, visitId, visitStartTime) as first_hit
  FROM `table name`, UNNEST(hits) as hits
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20211231'
)
WHERE hitType='PAGE'
) 
group by Page
order by Pageviews_Cnt desc
) as t left join Only_Bounces as b on b.page = t.page
order by Pageviews_Cnt desc



