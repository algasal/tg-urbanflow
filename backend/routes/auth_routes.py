from fastapi import APIRouter

auth_router = APIRouter(prefix="/auth", tags=["auth"])

@auth_router.post("/login")
def login(username: str, password: str):
    """
    endpoint de login
    """
    return {"message": f"User {username} logged in successfully."}

@auth_router.post("/register")
def register(username: str, password: str, email: str):
    """
    endpoint de registro
    """
    return {"message": f"User {username} registered successfully."}