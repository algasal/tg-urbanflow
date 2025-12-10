# security.py
from passlib.context import CryptContext
from datetime import datetime, timedelta
from jose import jwt

SECRET_KEY = "UM-SEGREDO-BEM-FORTE-AQUI"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 1440  # 24h

bcrypt_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def criar_token(dados: dict):
    dados_copy = dados.copy()
    exp = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    dados_copy.update({"exp": exp})
    token = jwt.encode(dados_copy, SECRET_KEY, algorithm=ALGORITHM)
    return token

def verificar_senha(senha_plana, senha_hash):
    return bcrypt_context.verify(senha_plana, senha_hash)

def gerar_hash(senha_plana):
    return bcrypt_context.hash(senha_plana)
