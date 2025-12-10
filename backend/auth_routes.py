# auth_routes.py
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session

from schemas import UsuarioSchema, LoginSchema
from models import Usuario
from dependencies import pegar_sessao
from security import gerar_hash, verificar_senha, criar_token

auth_router = APIRouter(prefix="/auth", tags=["Autenticação"])

# ---------------------------
#     CADASTRO
# ---------------------------
@auth_router.post("/cadastrar")
def registrar_usuario(dados: UsuarioSchema, db: Session = Depends(pegar_sessao)):
    usuario_existente = db.query(Usuario).filter(Usuario.email == dados.email).first()

    if usuario_existente:
        raise HTTPException(status_code=400, detail="Email já cadastrado.")

    senha_hash = gerar_hash(dados.senha)
    usuario = Usuario(
        nome=dados.nome,
        email=dados.email,
        senha=senha_hash
    )

    db.add(usuario)
    db.commit()
    db.refresh(usuario)

    return {"msg": "Usuário cadastrado com sucesso", "id": usuario.id}


# ---------------------------
#        LOGIN
# ---------------------------
@auth_router.post("/login")
def login(dados: LoginSchema, db: Session = Depends(pegar_sessao)):
    usuario = db.query(Usuario).filter(Usuario.email == dados.email).first()

    if not usuario:
        raise HTTPException(status_code=401, detail="Dados inválidos.")

    if not verificar_senha(dados.senha, usuario.senha):
        raise HTTPException(status_code=401, detail="Senha incorreta.")

    token = criar_token({"sub": str(usuario.id)})

    return {
        "msg": "Login OK",
        "token": token,
        "usuario": {
            "id": usuario.id,
            "nome": usuario.nome,
            "email": usuario.email
        }
    }
