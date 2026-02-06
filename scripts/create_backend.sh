#!/bin/bash

# Exit on error
set -e

echo "========================================"
echo "      Creating FastAPI Backend          "
echo "========================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKEND_DIR="$PROJECT_ROOT/backend"

# Create backend directory
if [ -d "$BACKEND_DIR" ]; then
    echo "Directory 'backend' already exists. Skipping creation."
else
    echo "--- Creating Backend Directory ---"
    mkdir -p "$BACKEND_DIR"
fi

# Create requirements.txt
echo "--- Creating requirements.txt ---"
cat > "$BACKEND_DIR/requirements.txt" <<EOF
fastapi
uvicorn
psycopg2-binary
EOF

# Create main.py
echo "--- Creating main.py ---"
cat > "$BACKEND_DIR/main.py" <<EOF
from fastapi import FastAPI

app = FastAPI()

@app.get("/api")
def read_root():
    return {"message": "Hello from FastAPI running on GCP!"}
EOF

echo "Backend setup complete at $BACKEND_DIR"