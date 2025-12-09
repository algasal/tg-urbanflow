from fastapi import Depends, HTTPException
from jose import jwt, JWTError
from sqlalchemy.orm import sessionmaker, Session

from models import db, Usuario
from security import SECRET_KEY, ALGORITHM, oauth2_schema


def pegar_sessao():
    Session = sessionmaker(bind=db)
    session = Session()
    try:
        yield session
    finally:
        session.close()

def verificar_token(token: str = Depends(oauth2_schema), session: Session = Depends(pegar_sessao)):
    try:
        dic_info = jwt.decode(token, SECRET_KEY, [ALGORITHM])
        id_usuario = int(dic_info.get("sub"))
    except JWTError:
        raise HTTPException(status_code=401, detail="Acesso negado")
    usuario_opt = session.query(Usuario).filter(Usuario.id == id_usuario).first()
    if not usuario_opt:
        raise HTTPException(status_code=401, detail="Usuario invalido")
    return usuario_opt