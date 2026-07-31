PROMPT === 09_parameters ===
SELECT name,value FROM v$parameter WHERE name IN ('compatible','db_name','db_unique_name','db_recovery_file_dest','db_recovery_file_dest_size');
/
