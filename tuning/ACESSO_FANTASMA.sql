-- Executar como SYS AS SYSDBA
-- Identifica o texto exato da query que iniciou a transação fantasma
SET LINESIZE 250 PAGESIZE 100
COLUMN sql_text FORMAT A80
COLUMN prev_sql_id FORMAT A15
COLUMN username FORMAT A15

SELECT s.inst_id, s.sid, s.username, s.prev_sql_id, q.sql_text
FROM   gv$session s
JOIN   gv$sql q ON s.prev_sql_id = q.sql_id AND s.inst_id = q.inst_id
WHERE  s.status = 'INACTIVE' 
  AND  s.taddr IS NOT NULL 
  AND  s.blocking_session IS NULL
  AND  s.username = 'USER_TESTE_PMON';