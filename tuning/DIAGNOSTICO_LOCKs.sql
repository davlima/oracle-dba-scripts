-- Executar como SYS AS SYSDBA
SET LINESIZE 250 PAGESIZE 100
COLUMN username FORMAT A15
COLUMN status FORMAT A10
COLUMN estado_transacao FORMAT A28
COLUMN evento_espera FORMAT A35
COLUMN object_name FORMAT A20

SELECT s.inst_id, s.sid, s.serial#, s.username, s.status, s.last_call_et || 's' AS ocioso,
       CASE 
           WHEN s.taddr IS NOT NULL AND s.blocking_session IS NULL THEN 'PERIGO: BLOCKER (INATIVA)'
           WHEN s.taddr IS NOT NULL AND s.blocking_session IS NOT NULL THEN 'VITIMA: LOCK WAIT'
           ELSE 'SEGURO: SEM TRANSACAO'
       END AS estado_transacao,
       s.event AS evento_espera, o.object_name
FROM   gv$session s
LEFT   JOIN gv$transaction t ON s.taddr = t.addr AND s.inst_id = t.inst_id
LEFT   JOIN gv$lock l ON s.sid = l.sid AND s.inst_id = l.inst_id AND l.type = 'TM'
LEFT   JOIN dba_objects o ON l.id1 = o.object_id
WHERE  s.type = 'USER' AND s.username = 'USER_TESTE_PMON'
ORDER  BY s.blocking_session NULLS FIRST, s.inst_id, s.sid;