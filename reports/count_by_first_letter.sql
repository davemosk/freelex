-- produce counts of entries by first letter/digraph

SELECT 
   CASE WHEN upper(substr(headword,1,1)) = 'N' AND upper(substr(headword,2,1)) = 'G' THEN 'NG'
        WHEN upper(substr(headword,1,1)) = 'W' AND upper(substr(headword,2,1)) = 'H' THEN 'WH'
   ELSE upper(substr(headword,1,1)) 
   END AS firstletter,
   count(*) FROM headword GROUP BY firstletter ORDER BY firstletter;
   