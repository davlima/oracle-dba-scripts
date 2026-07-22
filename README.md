# 🗄️ Oracle Database Repository

Este repositório é exclusivamente dedicado ao **armazenamento, controle de versão e padronização de scripts para Oracle Database** (12c a 23c), cobrindo ambientes Single Instance, Multitenant (CDB/PDB) e Real Application Clusters (RAC).

---

## 📁 Estrutura de Diretórios

```text
oracle-dba-scripts/
├── .gitignore               # Regras de exclusão para artefatos Oracle e sensíveis
├── README.md                # Documentação técnica do repositório
├── ddl/                     # Data Definition Language (Schemas, Tables, Indexes, Views)
├── dml/                     # Data Manipulation Language (Inserts, Updates, Fixes)
└── tuning/                  # Diagnóstico de Performance, AWR/ASH, SGA/PGA e PDBs
```

---

## 🎯 Detalhamento dos Diretórios

### 🔹 `ddl/`
Contém a definição de estrutura e objetos de banco de dados:
- Criação e alteração de tabelas, índices (B-Tree, Bitmap), sequences e views.
- Definição de PL/SQL (Packages, Procedures, Functions, Triggers, Types).
- Gestão de Tablespaces, Datafiles e Roles/Grants.

### 🔹 `dml/`
Scripts de movimentação, tratamento e carga de dados:
- Cargas lógicas, correções pontuais de dados e scripts de migração.
- Rotinas com controle estrito de transação (`COMMIT`, `ROLLBACK`, `SAVEPOINT`).
- Utilização de `FORALL` e `BULK COLLECT` para alta performance em PL/SQL.

### 🔹 `tuning/`
Consultas de diagnóstico, análise de performance e manutenção de instâncias:
- Análise de planos de execução (`EXPLAIN PLAN`, `DBMS_XPLAN`).
- Consultas a views de desempenho (`V$SESSION`, `V$SQL`, `V$SYSTEM_EVENT`, `V$ACTIVE_SESSION_HISTORY`).
- Gerenciamento de containers Multitenant (`CDB$ROOT` e PDBs).
- Coleta de estatísticas via `DBMS_STATS`.

---

## 🔒 Boas Práticas e Padrões de Código

1. **Cabeçalho de Scripts**: Todo script `.sql` deve iniciar com bloco de comentário contendo:
   - Autor, Data, Objetivo e Ticket/Issue de referência.
2. **Segurança**: Nunca hardcodear credenciais (`SYS`, `SYSTEM` ou usuários de aplicação) nos scripts.
3. **Formatos de Saída**: Utilizar formatação de SQL*Plus/SQLcl padrão (`SET LINESIZE`, `SET PAGESIZE`, `COLUMN`).
4. **Isolamento de PDBs**: Sempre especificar o contexto do container quando executando rotinas multitenant (`ALTER SESSION SET CONTAINER = <PDB_NAME>;`).

---

## 🚀 Versionamento e Envio para o GitHub

Para clonar ou publicar as alterações no GitHub (usuário `davlima`):

```bash
cd oracle-dba-scripts
git init
git add .
git commit -m "feat: inicializa estrutura isolada para Oracle Database"
git branch -M main
git remote add origin git@github.com:davlima/oracle-dba-scripts.git
git push -u origin main
```
