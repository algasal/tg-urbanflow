from fastapi import HTTPException, APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from dependencies import pegar_sessao, verificar_token
from schemas import UsuarioSchema, LoginSchema
from security import bcrypt_context, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES, SECRET_KEY

from models import Usuario
from jose import jwt
from datetime import datetime, timedelta, timezone

auth_router = APIRouter(prefix="/auth", tags=["auth"])

def criar_token(id_usuario, duracao_token=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)):
    data_expiracao = datetime.now(timezone.utc) + duracao_token
    dic_info = {"sub": str(id_usuario), "exp": data_expiracao}
    jwt_codificado = jwt.encode(dic_info, SECRET_KEY, algorithm=ALGORITHM)
    return jwt_codificado

@auth_router.post("/login")
async def login(login_schema: LoginSchema, session: Session = Depends(pegar_sessao)):
    """
        endpoint de login
    """

    usuario_opt = autenticar_usuario(session, login_schema.email, login_schema.senha)
    access_token = criar_token(usuario_opt.id)
    refresh_token = criar_token(usuario_opt.id, duracao_token=timedelta(days=7))
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "Bearer"
    }

@auth_router.post("/login-form")
async def login_form(dados_formulario: OAuth2PasswordRequestForm = Depends(), session: Session = Depends(pegar_sessao)):
    """
        endpoint de login
    """
    usuario_opt = autenticar_usuario(session, dados_formulario.username, dados_formulario.password)
    access_token = criar_token(usuario_opt.id)
    return {
        "access_token": access_token,
        "token_type": "Bearer"
    }

def autenticar_usuario(session, username, password):
    usuario_opt = session.query(Usuario).filter(Usuario.email == username).first()
    if not usuario_opt:
        raise HTTPException(status_code=400, detail="Email não registrado.")
    if not bcrypt_context.verify(password, usuario_opt.senha):
        raise HTTPException(status_code=400, detail="Email e/ou Senha incorretos(a).")
    return usuario_opt

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

@auth_router.get("/refresh")
async def refresh_token(usuario: Usuario = Depends(verificar_token)):
    """
    endpoint de refresh token
    """
    access_token = criar_token(usuario.id)
    return {
        "access_token": access_token,
        "token_type": "Bearer"
    }