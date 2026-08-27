-- =============================================================================
-- Laboratório: Identificação e Abate Seguro de Sessões (Idle vs Lock Contention)
-- Arquivo: 02_query_diagnostico_locks.sql
-- Objetivo: Mapear Blockers (INACTIVE com transação) vs Vítimas (Lock Wait)
-- Autor: David Campos de Lima
-- =============================================================================

SET LINESIZE 250
SET PAGESIZE 100
COLUMN username          FORMAT A15
COLUMN status            FORMAT A10
COLUMN ocioso            FORMAT A10
COLUMN estado_transacao  FORMAT A28
COLUMN evento_espera     FORMAT A35
COLUMN object_name       FORMAT A20
COLUMN blocking_session  FORMAT 999999

SELECT s.sid,
       s.serial#,
       s.username,
       s.status,
       s.last_call_et || 's' AS ocioso,
       s.blocking_session,
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
FROM   v$session s
LEFT   JOIN v$transaction t ON s.taddr = t.addr
LEFT   JOIN v$lock l ON s.sid = l.sid AND l.type = 'TM'
LEFT   JOIN dba_objects o ON l.id1 = o.object_id
WHERE  s.username = 'USER_TESTE_PMON'
  AND  s.type = 'USER'
ORDER  BY s.blocking_session NULLS FIRST, s.sid;

PROMPT ============================================================
PROMPT Interpretação:
PROMPT - PERIGO: BLOCKER (INATIVA) → sessão com transação aberta e ociosa
PROMPT - VITIMA: LOCK WAIT         → sessão aguardando o blocker
PROMPT - SEGURO: SEM TRANSACAO     → pode ser morta com mais tranquilidade
PROMPT ============================================================
