-- ====================================================================
-- Comandos Básicos de Gerenciamento Multitenant (CDB / PDB) no Oracle
-- ====================================================================

-- 1. Verificar o nome do container atual
SHOW CON_NAME;

-- 2. Listar todas as PDBs (Pluggable Databases) e seus status
SHOW PDBS;

-- 3. Alternar para um container PDB específico (Exemplo: ORCLPDB)
ALTER SESSION SET CONTAINER = ORCLPDB;

-- 4. Listar todos os schemas (usuários) no PDB atual
SELECT username, created 
FROM dba_users 
ORDER BY username;

-- 5. Alternar para outro PDB (Exemplo: PDBLAB)
ALTER SESSION SET CONTAINER = PDBLAB;

-- 6. Listar schemas do PDBLAB
SELECT username, created 
FROM dba_users 
ORDER BY username;

-- 7. Voltar para o container raiz (CDB$ROOT)
ALTER SESSION SET CONTAINER = CDB$ROOT;

-- 8. Consulta unificada (executada no CDB$ROOT) para listar schemas de PDBs específicos
    SET LINESIZE 150 PAGESIZE 100
    COLUMN pdb_name FORMAT A15
    COLUMN username FORMAT A30

SELECT c.name AS pdb_name, u.username, u.created
FROM cdb_users u
JOIN v$containers c ON u.con_id = c.con_id
WHERE c.name IN ('ORCLPDB', 'PDBLAB')
ORDER BY c.name, u.username;
