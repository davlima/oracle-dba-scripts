-- =============================================================================
-- Laboratório: Identificação e Abate Seguro de Sessões (Idle vs Lock Contention)
-- Arquivo: 01_setup_usuario_tabela.sql
-- Ambiente: Oracle 19c Multitenant (PDB)
-- Autor: David Campos de Lima
-- =============================================================================

-- Conecte-se como SYS AS SYSDBA no PDB (ex: orclpdb)
-- ALTER SESSION SET CONTAINER = ORCLPDB;

-- 1. Limpeza prévia (caso exista lixo de testes anteriores)
DROP USER user_teste_pmon CASCADE;

-- 2. Criação do usuário local no PDB + privilégios
CREATE USER user_teste_pmon IDENTIFIED BY oracle
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

GRANT CREATE SESSION, CREATE TABLE TO user_teste_pmon;

-- 3. Criação da tabela no schema do usuário de teste
CREATE TABLE user_teste_pmon.tabela_lock (
  id     NUMBER PRIMARY KEY,
  status VARCHAR2(20)
);

INSERT INTO user_teste_pmon.tabela_lock VALUES (1, 'LIBERADO');
COMMIT;

-- Confirmação
SELECT owner, table_name 
FROM   dba_tables 
WHERE  table_name = 'TABELA_LOCK';

PROMPT ============================================================
PROMPT Setup concluído com sucesso.
PROMPT Agora abra duas novas conexões com:
PROMPT   user_teste_pmon/oracle@localhost:1521/orclpdb
PROMPT ============================================================
