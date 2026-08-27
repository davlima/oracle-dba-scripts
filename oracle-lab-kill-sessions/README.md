# Laboratório Oracle: Identificação e Abate Seguro de Sessões (Idle vs Lock Contention)

**Autor:** David Campos de Lima  
**Ambiente testado:** Oracle Database 19c Multitenant (PDB)  
**Objetivo:** Simular e resolver de forma cirúrgica contenção de locks causada por sessões INACTIVE com transação aberta.

---

## Por que este laboratório existe?

Matar **todas** as sessões INACTIVE é um erro comum e perigoso.

Muitas sessões INACTIVE ainda possuem transação aberta (`taddr IS NOT NULL`).  
Elas são os verdadeiros **blockers**. Matá-las resolve a contenção.  
Matar sessões sem transação ou que são vítimas causa rollback desnecessário e impacto em produção.

Este laboratório ensina a diferenciar:

| Situação                        | Status   | taddr     | blocking_session | Ação recomendada          |
|--------------------------------|----------|-----------|------------------|---------------------------|
| Blocker (perigoso)             | INACTIVE | NOT NULL  | NULL             | **KILL** (topo da cadeia) |
| Vítima (Lock Wait)             | ACTIVE   | NOT NULL  | preenchido       | Não matar                 |
| Sessão segura (sem transação)  | INACTIVE | NULL      | NULL             | Pode matar com cautela    |

---

## Arquivos

| Arquivo                          | Descrição                                      |
|----------------------------------|------------------------------------------------|
| `01_setup_usuario_tabela.sql`    | Cria o usuário de teste e a tabela de lock     |
| `02_query_diagnostico_locks.sql` | Mapeia blockers vs vítimas com classificação   |
| `03_gerar_kill_commands.sql`     | Gera os `ALTER SYSTEM KILL SESSION` prontos    |

---

## Como executar o laboratório

### 1. Setup (aba SYSDBA no PDB)
```bash
sqlplus sys/senha@localhost:1521/orclpdb as sysdba
@01_setup_usuario_tabela.sql
```

### 2. Sessão A – Blocker (nova conexão)
```text
user_teste_pmon/oracle@localhost:1521/orclpdb
```
```sql
UPDATE tabela_lock SET status = 'BLOQUEADO' WHERE id = 1;
-- NÃO FAÇA COMMIT. Deixe a sessão aberta e inativa.
```

### 3. Sessão B – Vítima (outra conexão)
```text
user_teste_pmon/oracle@localhost:1521/orclpdb
```
```sql
UPDATE tabela_lock SET status = 'ESPERA' WHERE id = 1;
-- O cursor ficará travado (enq: TX - row lock contention)
```

### 4. Diagnóstico (aba SYSDBA)
```sql
@02_query_diagnostico_locks.sql
```

### 5. Gerar e executar o kill manualmente
```sql
@03_gerar_kill_commands.sql
```
Copie o comando gerado e execute. A sessão vítima deve destravar imediatamente.

---

## Métricas-chave utilizadas

- `V$SESSION.STATUS`
- `V$SESSION.TADDR` (transação aberta)
- `V$SESSION.BLOCKING_SESSION`
- `V$SESSION.LAST_CALL_ET` (tempo ocioso)
- `V$SESSION.EVENT`
- `V$TRANSACTION.USED_UBLK`
- `V$LOCK` + `DBA_OBJECTS`

---

## Benefício produtivo

- Resolve a contenção **sem** matar sessões que ainda podem estar fazendo trabalho válido.
- Evita rollbacks em cascata e perda de trabalho do usuário.
- Reduz o tempo de recuperação (MTTR) em incidentes reais de sexta-feira à tarde.
- Ensina o DBA a agir com precisão em vez de “matar tudo que está INACTIVE”.

---

## Limpeza

```sql
DROP USER user_teste_pmon CASCADE;
```
