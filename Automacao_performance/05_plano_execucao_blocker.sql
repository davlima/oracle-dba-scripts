-- =============================================================================
-- Arquivo: 05_plano_execucao_blocker.sql
-- Descrição: Extração do Execution Plan na memória usando o PREV_SQL_ID
-- Autor: David Campos de Lima
-- =============================================================================
SET PAGESIZE 0 LINESIZE 250

ACCEPT var_sql_id PROMPT 'Digite o PREV_SQL_ID do bloco ofensor (Script 04): '
ACCEPT var_child PROMPT 'Digite o CHILD (PREV_CHILD_NUMBER): '

SELECT * 
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&var_sql_id', '&var_child', 'ADVANCED'));
