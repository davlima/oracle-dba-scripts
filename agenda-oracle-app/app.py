"""
agenda_oracle_app/app.py
Backend Flask integrado ao Oracle Database 19c (modo Thin).
Tabela alvo: AGENDA_MCP
Colunas reais: ID_TAREFA, TIPO, TITULO, STATUS_KANBAN, PRIORIDADE, DATA_LIMITE
"""

import os

import oracledb
from dotenv import load_dotenv
from flask import Flask, jsonify, request, abort, render_template

# ---------------------------------------------------------------------------
# Configuração da aplicação
# ---------------------------------------------------------------------------
load_dotenv()

app = Flask(__name__)

# Parâmetros de conexão — lidos de variáveis de ambiente (.env local, nunca commitado)
DB_CONFIG = {
    "user":     os.getenv("DB_USER", "system"),
    "password": os.getenv("DB_PASSWORD"),
    "dsn":      f"{os.getenv('DB_HOST')}:{os.getenv('DB_PORT', '1521')}/{os.getenv('DB_SERVICE')}",
}

if not DB_CONFIG["password"] or not os.getenv("DB_HOST"):
    raise RuntimeError(
        "Variáveis de ambiente ausentes. Copie .env.example para .env e preencha "
        "DB_USER, DB_PASSWORD, DB_HOST, DB_PORT e DB_SERVICE."
    )


# ---------------------------------------------------------------------------
# Utilitário: obtém uma conexão em modo Thin (sem Oracle Client instalado)
# ---------------------------------------------------------------------------
def get_connection() -> oracledb.Connection:
    """Retorna uma conexão ativa com o banco Oracle em modo Thin."""
    return oracledb.connect(**DB_CONFIG)


# ---------------------------------------------------------------------------
# GET / — interface visual (Kanban)
# ---------------------------------------------------------------------------
@app.route("/")
def index():
    return render_template("index.html")


# ---------------------------------------------------------------------------
# GET /api/tarefas — lista todas as tarefas ordenadas por ID
# ---------------------------------------------------------------------------
@app.route("/api/tarefas", methods=["GET"])
def listar_tarefas():
    """Retorna todas as tarefas da tabela AGENDA_MCP em formato JSON."""
    sql = """
        SELECT id_tarefa, tipo, titulo, status_kanban, prioridade, data_limite
        FROM   agenda_mcp
        ORDER  BY id_tarefa
    """
    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(sql)
                colunas = [col[0].lower() for col in cur.description]
                rows = cur.fetchall()
                tarefas = []
                for row in rows:
                    d = dict(zip(colunas, row))
                    # Serializar DATE para string
                    if d.get("data_limite") is not None:
                        d["data_limite"] = d["data_limite"].isoformat()
                    tarefas.append(d)
        return jsonify(tarefas), 200
    except oracledb.DatabaseError as exc:
        (erro,) = exc.args
        return jsonify({"erro": erro.message}), 500


# ---------------------------------------------------------------------------
# POST /api/tarefas — insere uma nova tarefa com Bind Variables
# ---------------------------------------------------------------------------
@app.route("/api/tarefas", methods=["POST"])
def criar_tarefa():
    """
    Corpo JSON esperado:
        {
            "titulo":        "string (obrigatório)",
            "tipo":          "string (opcional)",
            "status_kanban": "string (opcional, default: 'TODO')",
            "prioridade":    "string (opcional, default: 'MEDIA')",
            "data_limite":   "YYYY-MM-DD (opcional)"
        }
    """
    dados = request.get_json(silent=True)
    if not dados or not dados.get("titulo"):
        abort(400, description="O campo 'titulo' é obrigatório.")

    data_limite = dados.get("data_limite") or None

    sql = """
        INSERT INTO agenda_mcp (tipo, titulo, status_kanban, prioridade, data_limite)
        VALUES (:tipo, :titulo, :status_kanban, :prioridade,
                CASE WHEN :data_limite IS NOT NULL
                     THEN TO_DATE(:data_limite, 'YYYY-MM-DD')
                     ELSE NULL END)
        RETURNING id_tarefa INTO :novo_id
    """
    bind = {
        "tipo":          dados.get("tipo", ""),
        "titulo":        dados["titulo"].strip(),
        "status_kanban": dados.get("status_kanban", "TODO"),
        "prioridade":    dados.get("prioridade", "MEDIA"),
        "data_limite":   data_limite,
        "novo_id":       None,
    }

    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                var_id = cur.var(oracledb.NUMBER)
                bind["novo_id"] = var_id
                cur.execute(sql, bind)
                conn.commit()
                novo_id = int(var_id.getvalue()[0])
        return jsonify({"mensagem": "Tarefa criada com sucesso.", "id": novo_id}), 201
    except oracledb.DatabaseError as exc:
        (erro,) = exc.args
        if "ORA-02290" in erro.message:
            return jsonify({
                "erro": "Valor inválido para tipo, status_kanban ou prioridade. "
                        "Consulte os valores aceitos no README."
            }), 400
        return jsonify({"erro": erro.message}), 500


# ---------------------------------------------------------------------------
# PUT /api/tarefas/<id> — atualiza campos da tarefa
# ---------------------------------------------------------------------------
@app.route("/api/tarefas/<int:id>", methods=["PUT"])
def atualizar_tarefa(id: int):
    """
    Corpo JSON esperado (pelo menos um campo é obrigatório):
        {
            "titulo":        "string (opcional)",
            "tipo":          "string (opcional)",
            "status_kanban": "string (opcional)",
            "prioridade":    "string (opcional)",
            "data_limite":   "YYYY-MM-DD (opcional)"
        }
    """
    dados = request.get_json(silent=True)
    if not dados:
        abort(400, description="Corpo JSON inválido ou vazio.")

    campos_permitidos = {"titulo", "tipo", "status_kanban", "prioridade"}
    atualizacoes = {k: v for k, v in dados.items() if k in campos_permitidos}

    # Trata data_limite separadamente (precisa de TO_DATE)
    data_limite = dados.get("data_limite")

    if not atualizacoes and data_limite is None:
        abort(400, description="Nenhum campo válido para atualizar foi informado.")

    set_parts = [f"{col} = :{col}" for col in atualizacoes]
    if data_limite is not None:
        set_parts.append("data_limite = TO_DATE(:data_limite, 'YYYY-MM-DD')")
        atualizacoes["data_limite"] = data_limite

    set_clause = ", ".join(set_parts)
    sql = f"UPDATE agenda_mcp SET {set_clause} WHERE id_tarefa = :id"
    atualizacoes["id"] = id

    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(sql, atualizacoes)
                if cur.rowcount == 0:
                    return jsonify({"erro": f"Tarefa com id={id} não encontrada."}), 404
                conn.commit()
        return jsonify({"mensagem": f"Tarefa {id} atualizada com sucesso."}), 200
    except oracledb.DatabaseError as exc:
        (erro,) = exc.args
        if "ORA-02290" in erro.message:
            return jsonify({
                "erro": "Valor inválido para tipo, status_kanban ou prioridade. "
                        "Consulte os valores aceitos no README."
            }), 400
        return jsonify({"erro": erro.message}), 500


# ---------------------------------------------------------------------------
# DELETE /api/tarefas/<id> — remove uma tarefa pelo ID
# ---------------------------------------------------------------------------
@app.route("/api/tarefas/<int:id>", methods=["DELETE"])
def deletar_tarefa(id: int):
    """Remove a tarefa com o ID especificado."""
    sql = "DELETE FROM agenda_mcp WHERE id_tarefa = :id"
    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(sql, {"id": id})
                if cur.rowcount == 0:
                    return jsonify({"erro": f"Tarefa com id={id} não encontrada."}), 404
                conn.commit()
        return jsonify({"mensagem": f"Tarefa {id} removida com sucesso."}), 200
    except oracledb.DatabaseError as exc:
        (erro,) = exc.args
        return jsonify({"erro": erro.message}), 500


# ---------------------------------------------------------------------------
# Handlers de erros HTTP padronizados
# ---------------------------------------------------------------------------
@app.errorhandler(400)
def bad_request(exc):
    return jsonify({"erro": exc.description}), 400


@app.errorhandler(404)
def not_found(exc):
    return jsonify({"erro": "Recurso não encontrado."}), 404


# ---------------------------------------------------------------------------
# Ponto de entrada
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    debug_mode = os.getenv("FLASK_DEBUG", "False").lower() == "true"
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5000")), debug=debug_mode)
