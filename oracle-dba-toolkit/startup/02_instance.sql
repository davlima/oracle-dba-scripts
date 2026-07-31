/*
----------------------------------------------------

Oracle DBA Toolkit

Autor:
David Lima

Descrição:
Consulta o status da instância Oracle, tempo de atividade (uptime) e modo de inicialização.

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
PROMPT Script: 02_instance.sql
PROMPT Descrição: Status da Instância e Uptime
PROMPT Compatibilidade: Oracle 19c / 21c / 23ai / 26ai
PROMPT ============================================

SET LINESIZE 200
SET PAGESIZE 100
SET VERIFY OFF
SET FEEDBACK ON

COLUMN instance_name FORMAT A15
COLUMN host_name FORMAT A30
COLUMN version FORMAT A15
COLUMN status FORMAT A12
COLUMN startup_time FORMAT A20
COLUMN logins FORMAT A12

SELECT instance_name, host_name, version, status, TO_CHAR(startup_time, 'YYYY-MM-DD HH24:MI:SS') AS startup_time, logins
FROM v$instance;

/
