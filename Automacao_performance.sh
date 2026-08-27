mkdir -p Automacao_performance
cd Automacao_performance

cat << 'EOF' > 01_setup_completo.sql
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
EOF

cat << 'EOF' > 02_simular_contencao.sql
-- =============================================================================
-- Arquivo: 02_simular_contencao.sql
-- Descrição: Instruções para forçar o Lock Contention (Executar em IDE/VS Code)
-- Autor: David Campos de Lima
-- =============================================================================

-- ABA 1 (O Blocker): Execute e NÃO faça commit. Deixe a sessão inativa.
UPDATE user_teste_pmon.tabela_lock SET status = 'BLOQUEADO' WHERE id = 1;

-- ABA 2 (A Vítima): Execute logo em seguida. O cursor ficará em Wait (hang).
UPDATE user_teste_pmon.tabela_lock SET status = 'ESPERA' WHERE id = 1;
EOF

cat << 'EOF' > 03_diagnostico_locks.sql
-- =============================================================================
-- Arquivo: 03_diagnostico_locks.sql
-- Descrição: Mapeamento Global (RAC/Single) de Blockers e Vítimas
-- Autor: David Campos de Lima
-- =============================================================================
SET LINESIZE 250 PAGESIZE 100
COLUMN username FORMAT A15
COLUMN status FORMAT A10
COLUMN estado_transacao FORMAT A28
COLUMN evento_espera FORMAT A35
COLUMN object_name FORMAT A20

SELECT s.inst_id, s.sid, s.serial#, s.username, s.status, s.last_call_et || 's' AS ocioso,
       CASE 
           WHEN s.taddr IS NOT NULL AND s.blocking_session IS NULL THEN 'PERIGO: BLOCKER (INATIVA)'
           WHEN s.taddr IS NOT NULL AND s.blocking_session IS NOT NULL THEN 'VITIMA: LOCK WAIT'
           ELSE 'SEGURO: SEM TRANSACAO'
       END AS estado_transacao,
       s.event AS evento_espera, o.object_name
FROM   gv$session s
LEFT   JOIN gv$transaction t ON s.taddr = t.addr AND s.inst_id = t.inst_id
LEFT   JOIN gv$lock l ON s.sid = l.sid AND s.inst_id = l.inst_id AND l.type = 'TM'
LEFT   JOIN dba_objects o ON l.id1 = o.object_id
WHERE  s.type = 'USER' AND s.username = 'USER_TESTE_PMON'
ORDER  BY s.blocking_session NULLS FIRST, s.inst_id, s.sid;
EOF

cat << 'EOF' > 04_captura_sql_fantasma.sql
-- =============================================================================
-- Arquivo: 04_captura_sql_fantasma.sql
-- Descrição: Captura do PREV_SQL_ID do cursor abandonado
-- Autor: David Campos de Lima
-- =============================================================================
SET LINESIZE 250 PAGESIZE 100
COLUMN sql_text FORMAT A80
COLUMN prev_sql_id FORMAT A15
COLUMN username FORMAT A15
COLUMN prev_child FORMAT 99999 HEADING 'CHILD'

SELECT s.inst_id, 
       s.sid, 
       s.username, 
       s.prev_sql_id, 
       s.prev_child_number AS prev_child,
       q.sql_text
FROM   gv$session s
JOIN   gv$sql q ON s.prev_sql_id = q.sql_id 
               AND s.inst_id = q.inst_id 
               AND s.prev_child_number = q.child_number
WHERE  s.status = 'INACTIVE' 
  AND  s.taddr IS NOT NULL 
  AND  s.blocking_session IS NULL
  AND  s.username = 'USER_TESTE_PMON';
EOF

cat << 'EOF' > 05_plano_execucao_blocker.sql
-- =============================================================================
-- Arquivo: 05_plano_execucao_blocker.sql
-- Descrição: Extração do Execution Plan na memória usando o PREV_SQL_ID
-- Autor: David Campos de Lima
-- =============================================================================
SET PAGESIZE 0 LINESIZE 250

ACCEPT var_sql_id PROMPT 'Digite o PREV_SQL_ID do bloco ofensor (Script 04): '
ACCEPT var_child PROMPT 'Digite o CHILD (PREV_CHILD_NUMBER): '

SELECT * 
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&var_sql_id', '&var_child', 'ADVANCED'));
EOF

cat << 'EOF' > 06_gerar_kill_commands_rac.sql
-- =============================================================================
-- Arquivo: 06_gerar_kill_commands_rac.sql
-- Descrição: Geração do comando KILL com roteamento de instância (@inst_id)
-- Autor: David Campos de Lima
-- =============================================================================
SET LINESIZE 250 PAGESIZE 100
COLUMN kill_command FORMAT A85

SELECT 'ALTER SYSTEM KILL SESSION ''' || s.sid || ',' || s.serial# || ',@' || s.inst_id || ''' IMMEDIATE;' AS kill_command
FROM   gv$session s
WHERE  s.type = 'USER'
  AND  s.status = 'INACTIVE'
  AND  s.taddr IS NOT NULL
  AND  s.blocking_session IS NULL
  AND  s.username NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'SYSMAN', 'AUDSYS')
ORDER  BY s.inst_id, s.sid;
EOF

cd ..
zip -r Automacao_performance.zip Automacao_performance/