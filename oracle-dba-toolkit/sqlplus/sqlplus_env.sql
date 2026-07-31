/*
----------------------------------------------------

Oracle DBA Toolkit

Autor:
David Lima

Descrição:
Configuração de ambiente padrão para execuções no SQL*Plus.

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
PROMPT Script: sqlplus_env.sql
PROMPT Descrição: Configuração de ambiente SQL*Plus
PROMPT Compatibilidade: Oracle 19c / 21c / 23ai / 26ai
PROMPT ============================================

SET LINESIZE 200
SET PAGESIZE 100
SET VERIFY OFF
SET FEEDBACK ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE UNLIMITED
SET TRIMSPOOL ON
SET TAB OFF

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF';
