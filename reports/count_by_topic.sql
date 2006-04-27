-- produce counts of entries by tags

SELECT tag, c FROM (
   SELECT tag, c FROM (
     SELECT tagid, count(*) AS c FROM headwordtag GROUP BY tagid
   ) z, tag WHERE z.tagid = tag.tagid
   UNION
   SELECT '--NONE--' AS tag, count(*) as c FROM headword WHERE headwordid NOT IN (SELECT DISTINCT headwordid FROM headwordtag)
) y
ORDER BY tag;


   