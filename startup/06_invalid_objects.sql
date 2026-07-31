PROMPT === 06_invalid_objects ===
SELECT owner,COUNT(*) invalid_objects FROM dba_objects WHERE status='INVALID' GROUP BY owner ORDER BY invalid_objects DESC;
/
