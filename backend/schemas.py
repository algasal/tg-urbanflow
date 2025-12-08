from pydantic import BaseModel
from typing import Optional

class UsuarioSchema():
    nome: str
    email: str
    senha: str

    class Config:
        from_attributes = True