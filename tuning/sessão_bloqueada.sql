-- =============================================================================
-- Laboratório: Identificação e Abate Seguro de Sessões (RAC Ready)
-- Arquivo: 02_query_diagnostico_locks_rac.sql
-- Objetivo: Mapear Blockers vs Vítimas Globalmente (GV$)
-- =============================================================================

SET LINESIZE 250
SET PAGESIZE 100
COLUMN inst              FORMAT 9999
COLUMN username          FORMAT A15
COLUMN status            FORMAT A10
COLUMN ocioso            FORMAT A10
COLUMN estado_transacao  FORMAT A28
COLUMN evento_espera     FORMAT A35
COLUMN object_name       FORMAT A20
COLUMN blk_inst          FORMAT 9999 HEADING 'B_INST'
COLUMN blk_sid           FORMAT 999999 HEADING 'B_SID'

ACCEPT nome_usuario PROMPT 'Digite o username (ou deixe em branco para todos): '

SELECT s.inst_id AS inst,
       s.sid,
       s.serial#,
       s.username,
       s.status,
       s.last_call_et || 's' AS ocioso,
       s.blocking_instance AS blk_inst,
       s.blocking_session AS blk_sid,
       CASE 
           WHEN s.taddr IS NOT NULL AND s.blocking_session IS NULL 
                THEN 'PERIGO: BLOCKER (INATIVA)'
           WHEN s.taddr IS NOT NULL AND s.blocking_session IS NOT NULL 
                THEN 'VITIMA: LOCK WAIT'
           WHEN s.blocking_session IS NOT NULL 
                THEN 'VITIMA: LOCK WAIT (sem tx?)'
           ELSE 'SEGURO: SEM TRANSACAO'
       END AS estado_transacao,
       s.event AS evento_espera,
       o.object_name,
       t.used_ublk AS blocos_undo
FROM   gv$session s
LEFT   JOIN gv$transaction t ON s.taddr = t.addr AND s.inst_id = t.inst_id
LEFT   JOIN gv$lock l ON s.sid = l.sid AND s.inst_id = l.inst_id AND l.type = 'TM'
LEFT   JOIN dba_objects o ON l.id1 = o.object_id
WHERE  s.type = 'USER'
  AND  s.username NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'SYSMAN', 'AUDSYS', 'C##OPT_DIR')
  AND  (s.username = UPPER('&nome_usuario') OR '&nome_usuario' IS NULL)
ORDER  BY s.blocking_instance NULLS FIRST, s.blocking_session NULLS FIRST, s.inst_id, s.sid;