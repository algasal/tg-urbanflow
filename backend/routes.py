import email

from fastapi import HTTPException, APIRouter, Depends
from sqlalchemy.orm import Session

from dependencies import pegar_sessao
from schemas import UsuarioSchema
from security import bcrypt_context
from models import Usuario

# ---------------------------USUARIO---------------------------------------------------

auth_router = APIRouter(prefix="/auth", tags=["auth"])

@auth_router.post("/login")
def login(email: str, password: str):
    """
    endpoint de login
    """
    return {"message": f"User {email} logged in successfully."}

@auth_router.post("/register")
async def register(usuario_schema: UsuarioSchema, session: Session = Depends(pegar_sessao)):
    """
    endpoint de registro
    """
    usuario_opt = session.query(Usuario).filter(Usuario.email == usuario_schema.email).first()

    if usuario_opt:
        raise HTTPException(status_code=400, detail="Email já registrado.")
    else:
        senha_criptografada = bcrypt_context.hash(usuario_schema.senha)
        novo_usuario = Usuario(nome=usuario_schema.nome, email=usuario_schema.email, senha=senha_criptografada)
        session.add(novo_usuario)
        session.commit()
        return {"message": f"User {novo_usuario.nome} registered successfully."}


# ---------------------------ESTACAO---------------------------------------------------
from consulta_estacao import LINHAS, ESTACOES, get_next_train

estacao_router = APIRouter(prefix="/estacao", tags=["estacao"])

@estacao_router.get("/proximo-trem")
def proximo_trem(linha: str, estacao: str):
    """
    Exemplo:
    /proximo-trem?linha=L9&estacao=PIN
    """

    if linha not in LINHAS:
        raise HTTPException(
            400,
            detail=f"Linha inválida. Use: {list(LINHAS.keys())}"
        )

    if estacao not in LINHAS[linha]:
        raise HTTPException(
            400,
            detail=f"Estação inválida para linha {linha}. Use: {LINHAS[linha]}"
        )

    if estacao not in ESTACOES:
        raise HTTPException(400, detail="Código de estação desconhecido.")

    # Chamada para a API
    next_train = get_next_train(linha, estacao)

    return {
        "linha": linha,
        "estacao_codigo": estacao,
        "estacao_nome": ESTACOES[estacao],
        "proximo_trem": next_train
    }