-- entries without definitions
select headword || '-' || headwordid AS entry, matapunauser.matapunauser AS user FROM headword, matapunauser
   WHERE (headword.owneruserid = matapunauser.matapunauserid)  AND
   ((headword.definition ISNULL)  OR  (headword.definition ~ '^\s*$'))
   AND mastersynonymheadwordid ISNULL
   AND mastervariantheadwordid ISNULL
   ORDER BY headword;
