<<<<<<< HEAD
# dependencies.py
from sqlalchemy.orm import sessionmaker
from models import db
from fastapi import Depends
from sqlalchemy.orm import Session
=======
from sqlalchemy.orm import sessionmaker

from models import db
>>>>>>> 7f7a48a8efcb129d17108b7e0a5d677114f78b17

SessionLocal = sessionmaker(bind=db, autoflush=False, autocommit=False)

def pegar_sessao():
    db_session = SessionLocal()
    try:
        yield db_session
    finally:
<<<<<<< HEAD
        db_session.close()
=======
        session.close()
>>>>>>> 7f7a48a8efcb129d17108b7e0a5d677114f78b17
