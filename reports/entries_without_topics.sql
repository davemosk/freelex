-- entries without tags
select headword || '-' || headwordid AS entry, matapunauser.matapunauser AS user FROM headword, matapunauser
   WHERE (headwordid NOT IN (SELECT DISTINCT headwordid FROM headwordtag) AND (headword.owneruserid = matapunauser.matapunauserid))
   ORDER BY collateseq, headword;
