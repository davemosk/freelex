CREATE TEMP TABLE s1 AS
SELECT date_trunc('month'::text, activity_date) AS month, matapunauser, count(headwordid) AS entries_updated FROM (

   SELECT date_trunc('day'::text, archivedate) AS activity_date, matapunauser.matapunauser, hwarchive.headwordid FROM hwarchive, matapunauser WHERE hwarchive.archiveuserid = matapunauser.matapunauserid
GROUP BY activity_date, matapunauser, headwordid

   ) AS daily_updates

GROUP BY date_trunc('month'::text, activity_date), matapunauser
ORDER BY date_trunc('month'::text, activity_date) DESC;

CREATE TEMP TABLE s2 AS
SELECT date_trunc('month'::text, activity_date) AS month, matapunauser, count(headwordid) AS entries_created FROM (

      SELECT date_trunc('day'::text, createdate) AS activity_date, matapunauser.matapunauser, headword.headwordid FROM headword, matapunauser WHERE headword.createuserid = matapunauser.matapunauserid


   ) AS daily_updates

GROUP BY date_trunc('month'::text, activity_date), matapunauser
ORDER BY date_trunc('month'::text, activity_date) DESC;

CREATE TEMP TABLE s3 AS
SELECT month, matapunauser, 0 as entries_created, entries_updated FROM s1  UNION
SELECT month, matapunauser, entries_created, 0 as entries_updated FROM s2;

SELECT to_char(date_trunc('month'::text, month), 'FMMonth FMYYYY'::text) AS xmonth, matapunauser, sum(entries_created) AS created, sum(entries_updated) AS updated FROM s3
GROUP BY month, matapunauser
ORDER BY month DESC;
