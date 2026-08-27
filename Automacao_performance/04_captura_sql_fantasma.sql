-- =============================================================================
-- Arquivo: 04_captura_sql_fantasma.sql
-- Descrição: Captura do PREV_SQL_ID do cursor abandonado
-- Autor: David Campos de Lima
-- =============================================================================
SET LINESIZE 250 PAGESIZE 100
COLUMN sql_text FORMAT A80
COLUMN prev_sql_id FORMAT A15
COLUMN username FORMAT A15
COLUMN prev_child FORMAT 99999 HEADING 'CHILD'

SELECT s.inst_id, 
       s.sid, 
       s.username, 
       s.prev_sql_id, 
       s.prev_child_number AS prev_child,
       q.sql_text
FROM   gv$session s
JOIN   gv$sql q ON s.prev_sql_id = q.sql_id 
               AND s.inst_id = q.inst_id 
               AND s.prev_child_number = q.child_number
WHERE  s.status = 'INACTIVE' 
  AND  s.taddr IS NOT NULL 
  AND  s.blocking_session IS NULL
  AND  s.username = 'USER_TESTE_PMON';
