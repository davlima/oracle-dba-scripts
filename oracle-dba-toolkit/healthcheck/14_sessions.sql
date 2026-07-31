/*
----------------------------------------------------

Oracle DBA Toolkit

Autor:
David Lima

Descrição:
Health Check - Resumo de Sessões Ativas e Inativas no Banco de Dados.

Compatibilidade:
Oracle 19c
Oracle 21c
Oracle 23ai
Oracle AI Database 26ai

Licença:
MIT

----------------------------------------------------
*/

PROMPT ============================================
PROMPT Oracle DBA Toolkit
PROMPT Script: healthcheck/14_sessions.sql
PROMPT Descrição: Resumo de Sessões Conectadas
PROMPT Compatibilidade: Oracle 19c / 21c / 23ai / 26ai
PROMPT ============================================

SET LINESIZE 200
SET PAGESIZE 100
SET VERIFY OFF
SET FEEDBACK ON

COLUMN status FORMAT A15
COLUMN type FORMAT A15
COLUMN total FORMAT 999,999

SELECT status, type, COUNT(*) AS total
FROM v$session
GROUP BY status, type
ORDER BY status, type;

/
