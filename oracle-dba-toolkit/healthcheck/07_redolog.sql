/*
----------------------------------------------------

Oracle DBA Toolkit

Autor:
David Lima

Descrição:
Health Check - Verificação de Grupos e Arquivos de Redo Log (Status, Tamanho em MB).

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
PROMPT Script: healthcheck/07_redolog.sql
PROMPT Descrição: Redo Log Groups & Status
PROMPT Compatibilidade: Oracle 19c / 21c / 23ai / 26ai
PROMPT ============================================

SET LINESIZE 200
SET PAGESIZE 100
SET VERIFY OFF
SET FEEDBACK ON

COLUMN group# FORMAT 9999
COLUMN thread# FORMAT 9999
COLUMN sequence# FORMAT 9999999
COLUMN bytes_mb FORMAT 999,999.99
COLUMN members FORMAT 999
COLUMN status FORMAT A15

SELECT group#, thread#, sequence#, ROUND(bytes/1024/1024, 2) AS bytes_mb, members, status
FROM v$log
ORDER BY group#;

/
