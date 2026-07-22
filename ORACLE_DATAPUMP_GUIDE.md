# 📦 Oracle Data Pump (EXPDP / IMPDP) - Guia Prático & Consultas de Rotina

Este documento fornece o procedimento operacional completo para exportação de schemas via Oracle Data Pump (`expdp`), além de uma biblioteca de consultas SQL rotineiras para monitoramento de diretórios, jobs ativos e solução de problemas.

---

## 🚀 1. Procedimento de Exportação de Schema (Exemplo: HR em PDB)

### Passo 1: Preparar o Diretório no Sistema Operacional (Linux)
```bash
mkdir -p /u01/app/oracle/admin/ORCLPDB/dpdump
```

### Passo 2: Configurar o DIRECTORY no Oracle Database
Conecte-se como `SYSDBA` e altere a sessão para a PDB desejada (`ORCLPDB`):

```sql
-- Alternar para o container da PDB
ALTER SESSION SET CONTAINER = ORCLPDB;

-- Criar/substituir o objeto DIRECTORY apontando para a pasta do SO
CREATE OR REPLACE DIRECTORY DATA_PUMP_DIR AS '/u01/app/oracle/admin/ORCLPDB/dpdump';

-- Conceder privilégios ao usuário/schema
GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR TO HR;
```

### Passo 3: Executar o EXPDP
Você pode executar o `expdp` utilizando conexão EZConnect via rede ou diretamente em sessão local:

**Opção A: Execução via EZConnect (com porta e serviço):**
```bash
expdp \"sys/sua_senha@//192.168.1.75:1521/ORCLPDB as sysdba\" \
      SCHEMAS=HR \
      DIRECTORY=DATA_PUMP_DIR \
      DUMPFILE=expdp_hr_orclpdb_%U.dmp \
      LOGFILE=expdp_hr_orclpdb.log \
      COMPRESSION=ALL
```

**Opção B: Execução Local no Servidor (usando `ORACLE_PDB_SID`):**
```bash
export ORACLE_PDB_SID=ORCLPDB

expdp \"/ as sysdba\" \
      SCHEMAS=HR \
      DIRECTORY=DATA_PUMP_DIR \
      DUMPFILE=expdp_hr_orclpdb_%U.dmp \
      LOGFILE=expdp_hr_orclpdb.log \
      COMPRESSION=ALL
```

---

## 🔍 2. Consultas SQL de Rotina (DBA Queries)

### 📂 2.1. Listar Diretórios Existentes no Banco (`DBA_DIRECTORIES`)

```sql
SET LINESIZE 180 PAGESIZE 100
COLUMN owner FORMAT A15
COLUMN directory_name FORMAT A25
COLUMN directory_path FORMAT A80

-- Listar todos os diretórios e seus caminhos no SO
SELECT owner, directory_name, directory_path 
FROM dba_directories 
ORDER BY owner, directory_name;
```

### ⚡ 2.2. Monitorar Jobs do Data Pump Ativos (`DBA_DATAPUMP_JOBS`)

```sql
SET LINESIZE 200 PAGESIZE 100
COLUMN owner_name FORMAT A15
COLUMN job_name FORMAT A25
COLUMN operation FORMAT A15
COLUMN job_mode FORMAT A15
COLUMN state FORMAT A15

-- Listar todos os jobs de export/import e seus estados
SELECT owner_name, 
       job_name, 
       operation, 
       job_mode, 
       state, 
       attached_sessions, 
       datapump_sessions
FROM dba_datapump_jobs
WHERE state NOT IN ('NOT RUNNING')
ORDER BY owner_name, job_name;
```

### ⏳ 2.3. Acompanhar o Progresso do Job em Tempo Real (`V$SESSION_LONGOPS`)

```sql
SET LINESIZE 180 PAGESIZE 100
COLUMN opname FORMAT A30
COLUMN target_desc FORMAT A20
COLUMN units FORMAT A10

-- Exibe progresso e tempo estimado de conclusao para jobs do Data Pump
SELECT sid, 
       serial#, 
       opname, 
       sofar, 
       totalwork, 
       ROUND(sofar/totalwork*100, 2) AS percent_complete,
       time_remaining AS seconds_remaining
FROM v$session_longops
WHERE totalwork > 0 
  AND sofar < totalwork
  AND opname LIKE '%DATAPUMP%'
ORDER BY sid;
```

### 🛠️ 2.4. Limpeza de Jobs Presos ou Órfãos (Stuck Jobs)

Se um job do Data Pump for interrompido abruptamente, a tabela de master pode continuar no banco. Para remover:

```sql
-- 1. Identificar o owner e job_name na dba_datapump_jobs
SELECT owner_name, job_name, state FROM dba_datapump_jobs;

-- 2. Eliminar a tabela master do job se o estado for NOT RUNNING ou EXECUTING preso
DROP TABLE <owner_name>.<job_name> PURGE;
```

Para cancelar um job ativo via cliente Data Pump:
```bash
# Reconectar ao job ativo
expdp \"/ as sysdba\" ATTACH=<owner_name>.<job_name>

# Dentro do prompt do expdp:
Export> STOP_JOB=IMMEDIATE
Are you sure you wish to stop this job ([yes]/no): yes
```

---

## 🛠️ 3. Solução de Problemas Comuns (Troubleshooting)

| Erro | Causa Principal | Solução |
| :--- | :--- | :--- |
| **`ORA-12541: TNS:no listener`** | O serviço do Listener do Oracle está inativo no servidor. | Iniciar o listener com `lsnrctl start`. |
| **`ORA-12504: TNS:listener was not given...`** | Falta do prefixo `//` na string EZConnect do `expdp`. | Ajustar para `sys/senha@//IP:PORTA/SERVICE_NAME`. |
| **`Listener supports no services`** | O listener acabou de iniciar e a instância ainda não registrou o serviço. | Executar `ALTER SYSTEM REGISTER;` no `sqlplus / as sysdba`. |
| **`ORA-39002` / `ORA-39070`** | O caminho da pasta do SO no `DIRECTORY` não existe ou falta permissão de escrita para o usuário `oracle`. | Garantir `mkdir -p` e permissões no sistema operacional. |
