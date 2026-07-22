# 📖 Guia Prático de Versionamento Git & DevOps

Este guia documenta o histórico de configuração inicial do seu ambiente, além de fornecer o passo a passo padronizado para **adicionar novos arquivos a este repositório** e **criar novos repositórios no GitHub**.

---

## 📌 Parte 1: O que já foi feito (Setup Inicial)

1. **Estrutura de Pastas Criada (`oracle-dba-scripts`)**:
   - `ddl/`: Para scripts de definição de objetos (tables, indexes, views, packages).
   - `dml/`: Para cargas, ajustes e correções de dados.
   - `tuning/`: Para consultas de performance, AWR, ASH e gerenciamento de PDBs.

2. **Proteção e Documentação**:
   - `.gitignore`: Configurado para ignorar arquivos temporários, logs (`*.log`, `*.trc`), dumps (`*.dmp`) e credenciais.
   - `README.md`: Documentação técnica profissional do repositório.

3. **Autenticação e Publicação no GitHub**:
   - Repositório remoto vinculado: `https://github.com/davlima/oracle-dba-scripts.git`.
   - Gerado **Personal Access Token (PAT)** no GitHub com permissão `repo`.
   - Ativado o **`credential.helper store`** no Linux (suas credenciais ficaram salvas para que os próximos `git push` não viagem pedindo senha).
   - Realizado o primeiro `git push -u origin main` com sucesso.

---

## 📝 Parte 2: Como adicionar NOVOS ARQUIVOS neste repositório (`oracle-dba-scripts`)

Sempre que você criar ou modificar um script SQL dentro de `ddl/`, `dml/` ou `tuning/`, siga este fluxo de 4 passos:

### Passo 1: Verificar o estado das alterações
```bash
cd /home/pop/oracle-dba-scripts
git status
```
*(O Git mostrará em vermelho os arquivos novos ou modificados).*

### Passo 2: Adicionar os arquivos ao staging (preparação)
```bash
# Para adicionar um arquivo específico:
git add ddl/minha_nova_tabela.sql

# OU para adicionar todos os arquivos novos e modificados de uma vez:
git add .
```

### Passo 3: Registrar o Commit (Histórico com mensagem clara)
```bash
git commit -m "feat(ddl): adiciona tabela de auditoria de usuarios"
```

### Passo 4: Enviar as alterações para o GitHub
```bash
git push
```
*(Como o token já foi salvo no seu computador, o push será executado direto sem pedir senha).*

---

## 🚀 Parte 3: Como criar e enviar OUTROS REPOSITÓRIOS para o GitHub

Caso você queira criar um novo repositório isolado (exemplo: `postgres-dba-scripts` ou `shell-automation`):

### Passo 1: Criar o repositório no site do GitHub
1. Acesse **https://github.com/new**
2. Nomeie o repositório (ex: `postgres-dba-scripts`).
3. Clique em **Create repository** *(deixe desmarcada a opção de criar README)*.

### Passo 2: Criar a pasta local e a estrutura no seu Linux
```bash
# 1. Criar a nova pasta do projeto e entrar nela
mkdir -p ~/postgres-dba-scripts/{ddl,dml,tuning}
cd ~/postgres-dba-scripts

# 2. Criar o arquivo README.md basico
echo "# 🐘 PostgreSQL DBA Scripts" > README.md

# 3. Criar o arquivo .gitignore
echo "*.log" > .gitignore
echo "*.tmp" >> .gitignore
```

### Passo 3: Inicializar o Git e vincular ao GitHub
```bash
# 1. Inicializar o repositório local
git init

# 2. Adicionar os arquivos
git add .

# 3. Fazer o primeiro commit
git commit -m "feat: inicializa repositorio postgresql"

# 4. Ajustar nome da branch
git branch -M main

# 5. Adicionar a URL remota HTTPS (substitua pelo nome do novo repo)
git remote add origin https://github.com/davlima/postgres-dba-scripts.git

# 6. Enviar para o GitHub
git push -u origin main
```
*(Nota: Como o `credential.helper store` já está ativo no seu sistema, o `git push` enviará o novo repositório automaticamente sem solicitar o token novamente!).*

---

## 💡 Convenções de Mensagens de Commit (Padrão DevOps)

Para manter o histórico do seu GitHub profissional, utilize prefixos padronizados nas mensagens:

- `feat:` Quando adicionar um arquivo ou funcionalidade nova.  
  *(Ex: `git commit -m "feat(tuning): adiciona query de fragmentacao de indices"`) *
- `fix:` Quando corrigir um erro em um script existente.  
  *(Ex: `git commit -m "fix(dml): corrige sintaxe de update em script de carga"`) *
- `docs:` Quando alterar ou criar arquivos de documentação.  
  *(Ex: `git commit -m "docs: atualiza README com novos procedimentos"`) *
- `refactor:` Quando reestruturar um script sem alterar sua função.  
  *(Ex: `git commit -m "refactor(shell): otimiza rotina de limpeza de logs"`) *
