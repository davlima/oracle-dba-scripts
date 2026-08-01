-- Query 1: Validacao Geral de Objetos e Status pos-carga
SET PAGESIZE 100 LINESIZE 200 VERIFY OFF FEEDBACK ON;

SELECT 
    object_type, 
    status, 
    COUNT(*) AS total_objects
FROM dba_objects 
WHERE owner = 'HR'
GROUP BY object_type, status
ORDER BY total_objects DESC;

-- Query 2: Mapeamento de Estado e Tipos de Constraints
SET PAGESIZE 100 LINESIZE 200 VERIFY OFF FEEDBACK ON;

SELECT 
    constraint_type, 
    status, 
    COUNT(*) AS total_constraints
FROM dba_constraints
WHERE owner = 'HR'
GROUP BY constraint_type, status
ORDER BY total_constraints DESC;

-- Query 3: Consumo de Armazenamento Fisico por PDB e Tablespace
SET PAGESIZE 100 LINESIZE 200 VERIFY OFF FEEDBACK ON;

SELECT 
    p.name AS pdb_name,
    t.tablespace_name,
    ROUND(SUM(d.bytes)/1024/1024, 2) AS size_mb_allocated
FROM v$containers p
JOIN cdb_data_files d ON p.con_id = d.con_id
JOIN cdb_tablespaces t ON d.tablespace_name = t.tablespace_name AND d.con_id = t.con_id
WHERE p.name = 'ORCLPDB'
GROUP BY p.name, t.tablespace_name;