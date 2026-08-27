-- =============================================================================
-- Arquivo: 06_gerar_kill_commands_rac.sql
-- Descrição: Geração do comando KILL com roteamento de instância (@inst_id)
-- Autor: David Campos de Lima
-- =============================================================================
SET LINESIZE 250 PAGESIZE 100
COLUMN kill_command FORMAT A85

SELECT 'ALTER SYSTEM KILL SESSION ''' || s.sid || ',' || s.serial# || ',@' || s.inst_id || ''' IMMEDIATE;' AS kill_command
FROM   gv$session s
WHERE  s.type = 'USER'
  AND  s.status = 'INACTIVE'
  AND  s.taddr IS NOT NULL
  AND  s.blocking_session IS NULL
  AND  s.username NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'SYSMAN', 'AUDSYS')
ORDER  BY s.inst_id, s.sid;
