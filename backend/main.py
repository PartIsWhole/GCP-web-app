import psycopg2
from psycopg2.extras import RealDictCursor
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List

app = FastAPI()

# Database Config
DB_HOST = "localhost"
DB_NAME = "app_db"
DB_USER = "admin"
DB_PASS = "admin@123"

# Pydantic Models
class UserBase(BaseModel):
    name: str
    email: str

class UserCreate(UserBase):
    pass

class User(UserBase):
    id: int

def get_db_connection():
    conn = psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        cursor_factory=RealDictCursor
    )
    return conn

def init_db():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL
            );
        """)
        conn.commit()
        cur.close()
        conn.close()
        print("Database initialized successfully.")
    except Exception as e:
        print(f"Error initializing database: {e}")

# Initialize DB on startup
init_db()

@app.get("/api/users", response_model=List[User])
def read_users():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM users ORDER BY id ASC")
    users = cur.fetchall()
    cur.close()
    conn.close()
    return users

@app.post("/api/users", response_model=User)
def create_user(user: UserCreate):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "INSERT INTO users (name, email) VALUES (%s, %s) RETURNING *",
            (user.name, user.email)
        )
        new_user = cur.fetchone()
        conn.commit()
        return new_user
    except psycopg2.errors.UniqueViolation:
        conn.rollback()
        raise HTTPException(status_code=400, detail="Email already exists")
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cur.close()
        conn.close()

@app.put("/api/users/{user_id}", response_model=User)
def update_user(user_id: int, user: UserCreate):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "UPDATE users SET name = %s, email = %s WHERE id = %s RETURNING *",
            (user.name, user.email, user_id)
        )
        updated_user = cur.fetchone()
        conn.commit()
        if updated_user is None:
            raise HTTPException(status_code=404, detail="User not found")
        return updated_user
    except psycopg2.errors.UniqueViolation:
        conn.rollback()
        raise HTTPException(status_code=400, detail="Email already exists")
    finally:
        cur.close()
        conn.close()

@app.delete("/api/users/{user_id}")
def delete_user(user_id: int):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM users WHERE id = %s RETURNING id", (user_id,))
    deleted_id = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    if deleted_id is None:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": "User deleted successfully"}
