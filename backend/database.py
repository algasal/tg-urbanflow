from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import Base

# Postgres connection
DATABASE_URL = "postgresql://postgres:postgres@localhost:5432/postgres"

engine = create_engine(DATABASE_URL)

# Session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create all tables if they don't exist
def init_db():
    Base.metadata.create_all(bind=engine)
