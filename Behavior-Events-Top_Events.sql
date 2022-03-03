/* Confirmation required with unsampled report */ 

WITH EVENT AS(
SELECT
  hits.eventInfo.eventCategory AS Category,
  COUNT(*) AS Events,
  COUNT(DISTINCT CONCAT(fullvisitorid,visitId, visitstartTime, COALESCE(hits.eventinfo.eventCategory,''), COALESCE(hits.eventinfo.eventaction,''), COALESCE(hits.eventinfo.eventlabel, ''))) AS UniqueEvents
FROM
  `table name` t, unnest(hits) AS hits
WHERE 1=1
  AND _TABLE_SUFFIX BETWEEN '20210101' AND '20211231' 
  AND hits.type='EVENT' 
  AND hits.eventInfo.eventCategory IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
)

SELECT SUM(Events) AS All_Event, SUM(UniqueEvents) AS All_Unique_Event FROM EVENT
