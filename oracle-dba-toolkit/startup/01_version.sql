/*
----------------------------------------------------

Oracle DBA Toolkit

Autor:
David Lima

Descrição:
Consulta a versão e detalhes do produto Oracle Database instalado.

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
PROMPT Script: 01_version.sql
PROMPT Descrição: Informações de Versão do Banco de Dados
PROMPT Compatibilidade: Oracle 19c / 21c / 23ai / 26ai
PROMPT ============================================

SET LINESIZE 200
SET PAGESIZE 100
SET VERIFY OFF
SET FEEDBACK ON

COLUMN product FORMAT A50 TRUNC
COLUMN version FORMAT A20 TRUNC
COLUMN status FORMAT A15 TRUNC

SELECT product, version, version_full, status 
FROM product_component_version;

/
