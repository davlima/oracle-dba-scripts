-- =============================================================================
-- Arquivo: 01_setup_completo.sql
-- Descrição: Recriação de usuário e provisionamento da tabela de testes
-- Autor: David Campos de Lima
-- Compatibilidade: Oracle 19c+ (Multitenant)
-- =============================================================================

DROP USER user_teste_pmon CASCADE;

CREATE USER user_teste_pmon IDENTIFIED BY oracle DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS;
GRANT CREATE SESSION, CREATE TABLE TO user_teste_pmon;

CREATE TABLE user_teste_pmon.tabela_lock (
    id NUMBER PRIMARY KEY,
    status VARCHAR2(20)
);

INSERT INTO user_teste_pmon.tabela_lock VALUES (1, 'LIBERADO');
COMMIT;
