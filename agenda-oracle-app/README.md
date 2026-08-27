# 📅 Agenda Oracle App

> Gerenciador de tarefas Kanban integrado ao Oracle Database 19c — backend Flask, frontend JS vanilla, zero dependências externas no cliente.

---

## Sumário

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Banco de Dados](#banco-de-dados)
- [Instalação e Execução](#instalação-e-execução)
- [API REST — Contrato Completo](#api-rest--contrato-completo)
- [Frontend — Kanban Board](#frontend--kanban-board)
- [Decisões de Design](#decisões-de-design)
- [Troubleshooting](#troubleshooting)
- [Contribuindo](#contribuindo)

---

## Visão Geral

O **Agenda Oracle App** é uma aplicação web full-stack de gerenciamento de tarefas em estilo **Kanban board**, construída para demonstrar integração profissional entre Python/Flask e Oracle Database.

| Camada | Tecnologia | Versão |
|---|---|---|
| Frontend | HTML5 + CSS3 + JavaScript vanilla | — |
| Backend | Python + Flask | 3.0.2 |
| Driver Oracle | python-oracledb (modo Thin) | 2.1.0 |
| Banco de dados | Oracle Database 19c | PDB (configurável via `.env`) |

**Destaques técnicos:**
- Bind Variables em 100% dos SQLs (zero SQL Injection)
- Modo Thin — sem Oracle Instant Client na máquina local
- `RETURNING INTO` — ID retornado sem segundo SELECT
- Constraints Oracle como única fonte de verdade para valores permitidos
- Credenciais isoladas em variáveis de ambiente (`.env`, nunca commitado)

---

## Arquitetura

```
┌──────────────────────────────────────────────────────────────┐
│                   CLIENTE (Navegador)                         │
│   http://127.0.0.1:5000                                       │
│                                                               │
│   ┌───────────────────────────────────────────────────────┐  │
│   │  index.html  (JS vanilla — fetch API)                 │  │
│   │                                                       │  │
│   │  [📌 TODO]   [⚙️ DOING]   [✅ DONE]                   │  │
│   │  Criar / Editar / Mover / Deletar cards               │  │
│   └───────────────────┬───────────────────────────────────┘  │
└───────────────────────│──────────────────────────────────────┘
                        │  HTTP/JSON  (REST API)
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                  BACKEND  (Flask — app.py)                    │
│   porta configurável via PORT (.env)                          │
│                                                               │
│   GET    /api/tarefas        →  SELECT + fetchall             │
│   POST   /api/tarefas        →  INSERT + RETURNING INTO       │
│   PUT    /api/tarefas/<id>   →  UPDATE dinâmico (SET gerado)  │
│   DELETE /api/tarefas/<id>   →  DELETE                        │
│                                                               │
│   Bind Variables em todos os DMLs                             │
│   Context managers (with conn / with cur)                     │
└──────────────────────┬───────────────────────────────────────┘
                       │  python-oracledb (Thin Mode)
                       │  TCP  DB_HOST:DB_PORT (.env)
                       ▼
┌──────────────────────────────────────────────────────────────┐
│                  ORACLE DATABASE 19c                          │
│         Service/Usuário configuráveis via .env                │
│                                                               │
│   Tabela: AGENDA_MCP                                          │
│   ID_TAREFA (IDENTITY PK) | TITULO | TIPO | STATUS | PRIO    │
│   CHECK: tipo IN ('ESTUDO','PROJETO','SUPORTE','CALL')        │
│   CHECK: status_kanban IN ('TODO','DOING','DONE')             │
│   CHECK: prioridade IN ('BAIXA','MEDIA','ALTA','URGENTE')     │
└──────────────────────────────────────────────────────────────┘
```

---

## Estrutura do Projeto

```
agenda_oracle_app/
├── app.py                  # Backend Flask — roteamento, conexão Oracle, API REST
├── requirements.txt        # Dependências Python (pinadas por versão)
├── .env.example             # Template de variáveis de ambiente (copie para .env)
├── .gitignore
├── README.md                # Esta documentação
├── templates/
│   └── index.html           # SPA Kanban — HTML + CSS + JS vanilla
└── static/                  # Assets externos (vazia por padrão)
```

---

## Banco de Dados

### Parâmetros de Conexão

Definidos via variáveis de ambiente — copie `.env.example` para `.env` e preencha:

| Variável | Descrição |
|---|---|
| `DB_USER` | Usuário Oracle |
| `DB_PASSWORD` | Senha (nunca versionar) |
| `DB_HOST` | Host/IP do banco |
| `DB_PORT` | Porta do listener (padrão `1521`) |
| `DB_SERVICE` | Service name / PDB |

> Modo driver: **Thin** — não requer Oracle Instant Client instalado na máquina.

### DDL — Criação da Tabela `AGENDA_MCP`

```sql
CREATE TABLE agenda_mcp (
    id_tarefa     NUMBER        GENERATED ALWAYS AS IDENTITY
                                CONSTRAINT pk_agenda PRIMARY KEY,
    titulo        VARCHAR2(200) NOT NULL,
    tipo          VARCHAR2(30)  CONSTRAINT ck_tipo
                                CHECK (tipo IN ('ESTUDO','PROJETO','SUPORTE','CALL')),
    status_kanban VARCHAR2(20)  NOT NULL
                                CONSTRAINT ck_status
                                CHECK (status_kanban IN ('TODO','DOING','DONE')),
    prioridade    VARCHAR2(10)  CONSTRAINT ck_prio
                                CHECK (prioridade IN ('BAIXA','MEDIA','ALTA','URGENTE')),
    data_limite   DATE
);
```

### Constraints CHECK — Valores Permitidos

> **Regra de ouro:** Oracle é case-sensitive nas constraints. O frontend e a API devem enviar **exatamente** os valores abaixo — maiúsculos, sem acentos, sem variações.

| Coluna | Valores aceitos | Obrigatório |
|---|---|---|
| `tipo` | `ESTUDO` `PROJETO` `SUPORTE` `CALL` | Não (pode ser nulo) |
| `status_kanban` | `TODO` `DOING` `DONE` | Sim |
| `prioridade` | `BAIXA` `MEDIA` `ALTA` `URGENTE` | Não (pode ser nulo) |

### Consultas de Manutenção

```sql
-- Listar todas as constraints da tabela
SELECT constraint_name, constraint_type, search_condition
FROM   user_constraints
WHERE  table_name = 'AGENDA_MCP';

-- Estrutura da tabela
DESCRIBE agenda_mcp;

-- Tarefas por status
SELECT status_kanban, COUNT(*) AS total
FROM   agenda_mcp
GROUP  BY status_kanban
ORDER  BY status_kanban;

-- Tarefas com prazo vencido e ainda abertas
SELECT id_tarefa, titulo, data_limite
FROM   agenda_mcp
WHERE  data_limite < SYSDATE
  AND  status_kanban != 'DONE';
```

---

## Instalação e Execução

### Pré-requisitos

| Requisito | Versão mínima | Observação |
|---|---|---|
| Python | 3.9+ | `python --version` |
| Oracle DB | 19c+ | Acessível em rede |
| Oracle Client | **não necessário** | driver Thin dispensa |

### Passo a passo

```bash
# 1. Clone o projeto
git clone https://github.com/davlima/agenda-oracle-app.git
cd agenda-oracle-app

# 2. Crie o ambiente virtual
python -m venv venv
source venv/bin/activate      # Linux / macOS
# venv\Scripts\activate       # Windows

# 3. Instale as dependências
pip install -r requirements.txt

# 4. Configure as credenciais
cp .env.example .env
# edite .env com seu usuário, senha, host, porta e service name

# 5. Suba o servidor
python app.py
```

Acesse: **http://127.0.0.1:5000**

---

## API REST — Contrato Completo

Todas as rotas retornam `Content-Type: application/json`.
Erros seguem o formato: `{ "erro": "<mensagem>" }`.

---

### `GET /api/tarefas`

Lista todas as tarefas ordenadas por `id_tarefa`.

**Resposta `200 OK`:**
```json
[
  {
    "id_tarefa": 1,
    "tipo": "ESTUDO",
    "titulo": "Revisar índices Oracle",
    "status_kanban": "TODO",
    "prioridade": "ALTA",
    "data_limite": "2026-09-01T00:00:00"
  }
]
```

---

### `POST /api/tarefas`

Insere nova tarefa. Usa `RETURNING INTO` para retornar o ID gerado.

**Body JSON:**
```json
{
  "titulo":        "Nome da tarefa (obrigatório)",
  "tipo":          "ESTUDO | PROJETO | SUPORTE | CALL",
  "status_kanban": "TODO | DOING | DONE          (default: TODO)",
  "prioridade":    "BAIXA | MEDIA | ALTA | URGENTE  (default: MEDIA)",
  "data_limite":   "YYYY-MM-DD                    (opcional)"
}
```

**Resposta `201 Created`:**
```json
{ "mensagem": "Tarefa criada com sucesso.", "id": 42 }
```

| HTTP | Causa |
|---|---|
| `400` | Campo `titulo` ausente ou vazio |
| `500` | Erro Oracle (ex.: violação de constraint) |

---

### `PUT /api/tarefas/<id>`

Atualiza campos da tarefa (SET dinâmico — só altera os campos enviados).

| HTTP | Causa |
|---|---|
| `400` | Corpo vazio ou sem campos válidos |
| `404` | Tarefa não encontrada |
| `500` | Violação de constraint Oracle |

---

### `DELETE /api/tarefas/<id>`

Remove a tarefa pelo ID.

**Resposta `200 OK`:**
```json
{ "mensagem": "Tarefa 42 removida com sucesso." }
```

| HTTP | Causa |
|---|---|
| `404` | Tarefa não encontrada |
| `500` | Erro Oracle |

---

### Exemplos `curl`

```bash
# Listar todas
curl http://localhost:5000/api/tarefas

# Criar
curl -X POST http://localhost:5000/api/tarefas \
     -H "Content-Type: application/json" \
     -d '{"titulo":"Estudar AWR","tipo":"ESTUDO","prioridade":"ALTA","data_limite":"2026-09-30"}'

# Mover para DOING
curl -X PUT http://localhost:5000/api/tarefas/1 \
     -H "Content-Type: application/json" \
     -d '{"status_kanban":"DOING"}'

# Marcar URGENTE
curl -X PUT http://localhost:5000/api/tarefas/1 \
     -H "Content-Type: application/json" \
     -d '{"prioridade":"URGENTE"}'

# Deletar
curl -X DELETE http://localhost:5000/api/tarefas/1
```

---

## Frontend — Kanban Board

Interface SPA em JavaScript vanilla, sem frameworks ou bibliotecas externas.

### Colunas do board

| Coluna | `status_kanban` no Oracle | Navegação |
|---|---|---|
| 📌 **TODO** | `TODO` | ▶ move para DOING |
| ⚙️ **DOING** | `DOING` | ◀ volta para TODO / ▶ avança para DONE |
| ✅ **DONE** | `DONE` | ◀ volta para DOING |

### Funcionalidades

| Feature | Comportamento |
|---|---|
| Filtro de busca | Filtra título e tipo em tempo real (sem requisição ao servidor) |
| Filtro de prioridade | Dropdown: ALTA / URGENTE / MEDIA / BAIXA |
| Criar tarefa | Modal — `tipo` é `<select>`, impede valor inválido |
| Editar tarefa | Mesmo modal pré-preenchido |
| Alerta de prazo | Vencida → laranja ⚠️ |
| Toast | Sucesso (verde) / erro (vermelho) com auto-dismiss 3s |
| XSS prevention | `esc()` sanitiza todos os dados antes de inserir no DOM |

---

## Decisões de Design

| Decisão | Justificativa |
|---|---|
| **Bind Variables em 100% dos SQLs** | Previne SQL Injection; Oracle reutiliza cursor → melhor performance em carga |
| **`RETURNING INTO` no INSERT** | ID da `IDENTITY` obtido atomicamente — seguro em concorrência, sem `SELECT MAX(id)` |
| **Modo Thin (`python-oracledb`)** | Zero dependência do Oracle Instant Client — roda em qualquer máquina com Python |
| **`with conn / with cur`** | Fecha cursor e conexão automaticamente mesmo em exceção — sem vazamento de recursos |
| **`commit()` explícito** | Controle transacional explícito — não depende de autocommit (que varia por driver) |
| **SET dinâmico no UPDATE** | Atualiza só os campos enviados — evita sobrescrever dados com `null` acidentalmente |
| **Constraints Oracle como fonte de verdade** | Valores permitidos vivem no banco — frontend se adapta, não o contrário; evita divergência |
| **`<select>` para `tipo` no frontend** | Impede envio de valor fora da CHECK constraint antes de chegar ao banco |
| **JS vanilla, sem frameworks** | Zero dependências, sem build step, carregamento instantâneo, manutenção trivial |
| **`esc()` para sanitização DOM** | Previne XSS ao renderizar strings do banco diretamente em innerHTML |
| **Credenciais via `.env`** | Nenhuma senha ou host commitado no repositório |

---

## Troubleshooting

### ORA-02290: check constraint violated

Valor enviado não pertence ao conjunto da `CHECK constraint`.

```sql
-- Consulte os valores aceitos diretamente no banco
SELECT constraint_name, search_condition
FROM   user_constraints
WHERE  table_name = 'AGENDA_MCP' AND constraint_type = 'C';
```

Garanta que `status_kanban`, `tipo` e `prioridade` usem exatamente os valores da seção [Constraints CHECK](#constraints-check--valores-permitidos).

---

### ORA-12541 / ORA-12170: falha de conexão

```bash
ping $DB_HOST          # rede acessível?
telnet $DB_HOST 1521   # porta aberta?

# No servidor Oracle:
lsnrctl status          # listener rodando?
```

---

### Flask não inicia — ModuleNotFoundError

```bash
which python   # deve apontar para venv/bin/python
pip install -r requirements.txt
```

---

### RuntimeError: variáveis de ambiente ausentes

O `app.py` valida na subida que `DB_PASSWORD` e `DB_HOST` estão definidos. Confirme que `.env` existe (copiado de `.env.example`) e está preenchido.

---

## Contribuindo

1. Crie uma branch: `git checkout -b feat/nova-funcionalidade`
2. Mantenha **Bind Variables** em todos os SQLs novos — sem f-strings montando SQL
3. Nunca versione credenciais — use `.env` (já está no `.gitignore`)
4. Ao alterar valores permitidos de `tipo`, `status_kanban` ou `prioridade`:
   - **Primeiro** altere a `CHECK constraint` no Oracle (`ALTER TABLE ... DROP CONSTRAINT / ADD CONSTRAINT`)
   - **Depois** atualize o `<select>` no `index.html`
   - A API não precisa mudar — ela não valida os valores, delega ao Oracle
