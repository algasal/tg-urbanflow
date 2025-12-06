from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from consulta_estacao import get_next_train, ESTACOES, LINHAS

from routes.auth_routes import auth_router

app = FastAPI(title="UrbanFlow Backend", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)

@app.get("/proximo-trem")
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


if __name__ == "__main__":
    uvicorn.run(app, host="localhost", port=8000)
