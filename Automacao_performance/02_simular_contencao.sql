-- =============================================================================
-- Arquivo: 02_simular_contencao.sql
-- Descrição: Instruções para forçar o Lock Contention (Executar em IDE/VS Code)
-- Autor: David Campos de Lima
-- =============================================================================

-- ABA 1 (O Blocker): Execute e NÃO faça commit. Deixe a sessão inativa.
UPDATE user_teste_pmon.tabela_lock SET status = 'BLOQUEADO' WHERE id = 1;

-- ABA 2 (A Vítima): Execute logo em seguida. O cursor ficará em Wait (hang).
UPDATE user_teste_pmon.tabela_lock SET status = 'ESPERA' WHERE id = 1;
