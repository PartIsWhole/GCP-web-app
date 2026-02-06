#!/bin/bash

# Exit on error
set -e

echo "========================================"
echo "      Updating Backend with DB Code     "
echo "========================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKEND_DIR="$PROJECT_ROOT/backend"

# Overwrite main.py with DB connection logic
cat > "$BACKEND_DIR/main.py" <<EOF
import psycopg2
from fastapi import FastAPI

app = FastAPI()

# Database Config
DB_HOST = "localhost"
DB_NAME = "app_db"
DB_USER = "app_user"
DB_PASS = "secure_password"

def get_db_connection():
    conn = psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )
    return conn

@app.get("/api")
def read_root():
    return {"message": "Hello from FastAPI running on GCP!"}

@app.get("/api/db-test")
def test_db():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT version()')
        db_version = cur.fetchone()
        cur.close()
        conn.close()
        return {"status": "success", "db_version": db_version[0]}
    except Exception as e:
        return {"status": "error", "message": str(e)}
EOF

# Restart Supervisor to apply changes
echo "--- Restarting FastAPI Service ---"
sudo supervisorctl restart fastapi

echo "Backend updated and restarted."