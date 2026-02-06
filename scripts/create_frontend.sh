#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "========================================"
echo "      Creating React Frontend (Vite)    "
echo "========================================"

# Determine project root relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

# Check if frontend folder already exists
if [ -d "$FRONTEND_DIR" ]; then
    echo "Directory 'frontend' already exists. Skipping creation."
    exit 0
fi

cd "$PROJECT_ROOT"

# Initialize Vite app with React template
# -y: Automatically answer yes to installing create-vite if needed
echo "--- Scaffolding App ---"
npm create -y vite@latest frontend -- --template react

# Install dependencies
echo "--- Installing Dependencies ---"
cd "$FRONTEND_DIR"
npm install

# Create a basic App.jsx
echo "--- Configuring Basic App.jsx ---"
cat > src/App.jsx <<EOF
import { useState } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div style={{ textAlign: 'center', padding: '2rem' }}>
      <h1>React + FastAPI + Postgres</h1>
      <p>Frontend is running successfully.</p>
      <button onClick={() => setCount((count) => count + 1)}>
        Count is {count}
      </button>
    </div>
  )
}

export default App
EOF

echo "========================================"
echo "Frontend setup complete!"
echo "Run 'cd frontend && npm run dev' to start."
echo "========================================"