/*
----------------------------------------------------

Oracle DBA Toolkit

Autor:
David Lima

Descrição:
Consulta os serviços registrados no banco de dados.

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
PROMPT Script: 07_services.sql
PROMPT Descrição: Serviços do Banco de Dados
PROMPT Compatibilidade: Oracle 19c / 21c / 23ai / 26ai
PROMPT ============================================

SET LINESIZE 200
SET PAGESIZE 100
SET VERIFY OFF
SET FEEDBACK ON

COLUMN service_id FORMAT 9999
COLUMN name FORMAT A35
COLUMN network_name FORMAT A35

SELECT service_id, name, network_name
FROM dba_services
ORDER BY service_id;

/
