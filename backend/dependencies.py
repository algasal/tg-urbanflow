# dependencies.py
from sqlalchemy.orm import sessionmaker
from models import db
from fastapi import Depends
from sqlalchemy.orm import Session

SessionLocal = sessionmaker(bind=db, autoflush=False, autocommit=False)

def pegar_sessao():
    db_session = SessionLocal()
    try:
        yield db_session
    finally:
        db_session.close()
