/*
----------------------------------------------------

Oracle DBA Toolkit

Autor:
David Lima

Descrição:
Consulta o registro de componentes do banco de dados (DBA_REGISTRY) e seus respectivos status.

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
PROMPT Script: 05_registry.sql
PROMPT Descrição: Componentes do Banco e Status (DBA_REGISTRY)
PROMPT Compatibilidade: Oracle 19c / 21c / 23ai / 26ai
PROMPT ============================================

SET LINESIZE 200
SET PAGESIZE 100
SET VERIFY OFF
SET FEEDBACK ON

COLUMN comp_id FORMAT A15
COLUMN comp_name FORMAT A40
COLUMN version FORMAT A15
COLUMN status FORMAT A12

SELECT comp_id, comp_name, version, status
FROM dba_registry
ORDER BY comp_id;

/
