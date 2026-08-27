-- Executar conectado como SYS AS SYSDBA apontando para o PDB
DROP USER user_teste_pmon CASCADE;

CREATE USER user_teste_pmon IDENTIFIED BY oracle DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS;
GRANT CREATE SESSION, CREATE TABLE TO user_teste_pmon;

-- Cria a tabela e insere o registro inicial (commitado)
CREATE TABLE user_teste_pmon.tabela_lock (
    id NUMBER PRIMARY KEY,
    status VARCHAR2(20)
);
INSERT INTO user_teste_pmon.tabela_lock VALUES (1, 'LIBERADO');
COMMIT;