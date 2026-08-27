-- =============================================================================
-- Laboratório: Identificação e Abate Seguro de Sessões (Idle vs Lock Contention)
-- Arquivo: 03_gerar_kill_commands.sql
-- Objetivo: Gerar os comandos ALTER SYSTEM KILL SESSION prontos para execução manual
-- Autor: David Campos de Lima
-- =============================================================================
-- IMPORTANTE:
-- Esta query NÃO mata ninguém.
-- Ela apenas lista os comandos das sessões que são:
--   - INACTIVE
--   - Possuem transação aberta (taddr IS NOT NULL)
--   - Não estão esperando ninguém (blocking_session IS NULL) → topo da cadeia
-- =============================================================================

SET LINESIZE 250
SET PAGESIZE 100
COLUMN sid            FORMAT 99999
COLUMN serial#        FORMAT 99999
COLUMN status         FORMAT A10
COLUMN ocioso         FORMAT A10
COLUMN kill_command   FORMAT A75

SELECT sid,
       serial#,
       status,
       last_call_et || 's' AS ocioso,
       'ALTER SYSTEM KILL SESSION ''' || sid || ',' || serial# || ''' IMMEDIATE;' AS kill_command
FROM   v$session
WHERE  type = 'USER'
  AND  status = 'INACTIVE'
  AND  taddr IS NOT NULL                -- Tem transação aberta
  AND  blocking_session IS NULL         -- É o topo da cadeia (não espera ninguém)
  AND  username = 'USER_TESTE_PMON'
ORDER  BY sid;

PROMPT ============================================================
PROMPT Copie o(s) comando(s) gerado(s) e execute manualmente.
PROMPT Após o kill, a sessão vítima deve destravar imediatamente.
PROMPT ============================================================
