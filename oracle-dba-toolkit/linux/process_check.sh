#!/bin/bash
# ----------------------------------------------------
# Oracle DBA Toolkit
# Autor: David Lima
# Descrição: Valida os processos Oracle PMON, Listener, Oracle Home e utilitários.
# Licença: MIT
# ----------------------------------------------------

echo "============================================"
echo "Oracle DBA Toolkit - Status de Processos OS"
echo "============================================"

echo "[1] Processos PMON ativos:"
ps -ef | grep [p]mon_ || echo "Nenhum processo PMON localizado."

echo ""
echo "[2] Status do Listener:"
if command -v lsnrctl &> /dev/null; then
    lsnrctl status
else
    echo "lsnrctl não encontrado no PATH atual."
fi

echo ""
echo "[3] Variáveis de Ambiente Oracle:"
echo "ORACLE_HOME = ${ORACLE_HOME:-Não definido}"
echo "ORACLE_SID  = ${ORACLE_SID:-Não definido}"
