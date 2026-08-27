-- =============================================================================
-- Laboratório: Identificação e Abate Seguro de Sessões (RAC Ready)
-- Arquivo: 03_gerar_kill_commands_rac.sql
-- Objetivo: Gerar comandos KILL SESSION formatados para Cluster
-- =============================================================================

SET LINESIZE 250
SET PAGESIZE 100
COLUMN inst_id        FORMAT 9999
COLUMN sid            FORMAT 99999
COLUMN serial#        FORMAT 99999
COLUMN status         FORMAT A10
COLUMN ocioso         FORMAT A10
COLUMN kill_command   FORMAT A85

ACCEPT nome_usuario PROMPT 'Digite o username (ou deixe em branco para todos): '

SELECT s.inst_id,
       s.sid,
       s.serial#,
       s.status,
       s.last_call_et || 's' AS ocioso,
       'ALTER SYSTEM KILL SESSION ''' || s.sid || ',' || s.serial# || ',@' || s.inst_id || ''' IMMEDIATE;' AS kill_command
FROM   gv$session s
WHERE  s.type = 'USER'
  AND  s.status = 'INACTIVE'
  AND  s.taddr IS NOT NULL
  AND  s.blocking_session IS NULL
  AND  s.username NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'SYSMAN', 'AUDSYS', 'C##OPT_DIR')
  AND  (s.username = UPPER('&nome_usuario') OR '&nome_usuario' IS NULL)
ORDER  BY s.inst_id, s.sid;