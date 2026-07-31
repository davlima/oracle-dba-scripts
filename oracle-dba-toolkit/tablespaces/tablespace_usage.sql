/*
----------------------------------------------------

Oracle DBA Toolkit

Autor:
David Lima

Descrição:
Consulta a utilização detalhada dos Tablespaces (Total MB, Usado MB, Livre MB e % Usado).

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
PROMPT Script: tablespace_usage.sql
PROMPT Descrição: Utilização de Espaço por Tablespace
PROMPT Compatibilidade: Oracle 19c / 21c / 23ai / 26ai
PROMPT ============================================

SET LINESIZE 200
SET PAGESIZE 100
SET VERIFY OFF
SET FEEDBACK ON

COLUMN tablespace_name FORMAT A30
COLUMN size_mb FORMAT 999,999,999.99
COLUMN used_mb FORMAT 999,999,999.99
COLUMN free_mb FORMAT 999,999,999.99
COLUMN pct_used FORMAT 999.99

SELECT 
    df.tablespace_name,
    ROUND(df.total_bytes / 1024 / 1024, 2) AS size_mb,
    ROUND((df.total_bytes - NVL(f.free_bytes, 0)) / 1024 / 1024, 2) AS used_mb,
    ROUND(NVL(f.free_bytes, 0) / 1024 / 1024, 2) AS free_mb,
    ROUND(((df.total_bytes - NVL(f.free_bytes, 0)) / df.total_bytes) * 100, 2) AS pct_used
FROM 
    (SELECT tablespace_name, SUM(bytes) AS total_bytes FROM dba_data_files GROUP BY tablespace_name) df
LEFT JOIN 
    (SELECT tablespace_name, SUM(bytes) AS free_bytes FROM dba_free_space GROUP BY tablespace_name) f
ON df.tablespace_name = f.tablespace_name
ORDER BY pct_used DESC;

/
