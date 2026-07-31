/*
----------------------------------------------------

Oracle DBA Toolkit

Autor:
David Lima

Descrição:
Consulta o status e modo de abertura dos Pluggable Databases (PDBs).

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
PROMPT Script: 04_pdb.sql
PROMPT Descrição: Status e Open Mode dos PDBs
PROMPT Compatibilidade: Oracle 19c / 21c / 23ai / 26ai
PROMPT ============================================

SET LINESIZE 200
SET PAGESIZE 100
SET VERIFY OFF
SET FEEDBACK ON

COLUMN con_id FORMAT 9999
COLUMN name FORMAT A30
COLUMN open_mode FORMAT A15
COLUMN restricted FORMAT A10

SELECT con_id, name, open_mode, restricted
FROM v$pdbs
ORDER BY con_id;

/
