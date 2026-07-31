/*
----------------------------------------------------

Oracle DBA Toolkit

Autor:
David Lima

Descrição:
Consulta informações gerais do banco de dados (DBID, Nome, Log Mode, Open Mode, Role).

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
PROMPT Script: 03_database.sql
PROMPT Descrição: Informações Gerais do Banco de Dados
PROMPT Compatibilidade: Oracle 19c / 21c / 23ai / 26ai
PROMPT ============================================

SET LINESIZE 200
SET PAGESIZE 100
SET VERIFY OFF
SET FEEDBACK ON

COLUMN dbid FORMAT 99999999999
COLUMN name FORMAT A12
COLUMN log_mode FORMAT A15
COLUMN open_mode FORMAT A20
COLUMN database_role FORMAT A20

SELECT dbid, name, log_mode, open_mode, database_role
FROM v$database;

/
