# Documentação: `tablespace_usage.sql`

## Objetivo
Consultar o tamanho total, espaço utilizado, espaço livre e percentual de utilização (`% Usado`) de cada Tablespace no banco de dados Oracle.

## Quando Usar
- Durante rotinas de monitoramento diário ou **Health Check**.
- Antes e depois de grande volume de carga de dados.
- Para identificar antecipadamente tablespaces próximos do limite de capacidade.

## Exemplo de Execução
No SQL*Plus:
```sql
@tablespaces/tablespace_usage.sql
```

## Saída Esperada
```text
============================================
Oracle DBA Toolkit
Script: tablespace_usage.sql
Descrição: Utilização de Espaço por Tablespace
Compatibilidade: Oracle 19c / 21c / 23ai / 26ai
============================================

TABLESPACE_NAME                       SIZE_MB        USED_MB        FREE_MB   PCT_USED
------------------------------ -------------- -------------- -------------- ----------
SYSTEM                                 950.00         910.25          39.75      95.82
SYSAUX                                1200.00        1050.50         149.50      87.54
USERS                                  500.00         120.00         380.00      24.00
UNDOTBS1                               300.00          45.00         255.00      15.00

4 linhas selecionadas.
```
