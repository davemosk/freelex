-- entries without glosses
select headword || '-' || headwordid AS entry, matapunauser.matapunauser AS user FROM headword, matapunauser
   WHERE (headword.owneruserid = matapunauser.matapunauserid)  AND
   ((headword.gloss ISNULL)  OR  (headword.gloss ~ '^\s*$'))
   ORDER BY collateseq, headword;
