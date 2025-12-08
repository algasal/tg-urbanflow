import os

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY")

app = FastAPI(title="UrbanFlow Backend", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

import routes

app.include_router(routes.auth_router)
app.include_router(routes.estacao_router)

if __name__ == "__main__":
    uvicorn.run(app, host="localhost", port=8000)
