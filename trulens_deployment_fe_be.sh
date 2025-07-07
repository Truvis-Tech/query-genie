#!/bin/bash

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

MODE=${1:-public}

echo -e "${GREEN}🔧 Running setup in '$MODE' mode...${NC}"

abort() {
    echo -e "${RED}❌ $1${NC}" >&2
    exit 1
}

log() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 🧹 Clean up old folders
rm -rf trulens query-genie demo-trulens-ui trulens_repo || true

# 🎯 Create fresh trulens folder
mkdir -p trulens || abort "Failed to create 'trulens' folder"

if [ "$MODE" = "private" ]; then
    echo "🔄 Cloning backend repo from private GitLab..."
    git config --global http.sslVerify false
    git clone https://192.168.1.10:8888/truvis/trulens.git trulens_repo || abort "Failed to clone backend repo"

    echo "📦 Building .whl file..."
    cd trulens_repo
    python setup.py bdist_wheel || abort "Failed to build .whl file"
    WHL_FILE=$(ls dist/*.whl | head -n 1) || abort "No .whl file found"
    cd ..

    cp "$WHL_FILE" trulens/ || abort "Failed to copy .whl to trulens/"
    log ".whl file copied to trulens/"

    echo "🔄 Cloning frontend repo from private GitLab..."
    git clone https://192.168.1.10:8888/truvis/demo-trulens-ui.git || abort "Failed to clone frontend repo"

    echo "🛠️  Running frontend build..."
    cd demo-trulens-ui
    npm install || abort "npm install failed"
    npm run build || abort "npm build failed"
    cd ..
    cp -r demo-trulens-ui/dist trulens/ || abort "Failed to copy frontend dist to trulens/"
    log "Frontend dist copied to trulens/"

else
    echo "🔄 Cloning public query-genie repo..."
    git clone https://github.com/Truvis-Tech/query-genie.git || abort "Failed to clone public repo"

    cd query-genie || abort "Cannot enter query-genie"

    WHL_FILE=$(find trulens -name "*.whl" | head -n 1) || abort "No .whl file found inside trulens/"
    cp "$WHL_FILE" ../trulens/ || abort "Failed to copy .whl from nested folder"

    DIST_FOLDER=$(find frontend -type d -name dist | head -n 1) || abort "No dist folder found inside frontend/"
    cp -r "$DIST_FOLDER" ../trulens/ || abort "Failed to copy dist folder from nested folder"

    cd ..
    rm -rf query-genie
    log "Copied .whl and dist from public repo and cleaned up"
fi

### 🐍 Setup Python Virtual Environment
cd trulens || abort "Failed to enter trulens directory"

echo "🐍 Creating virtual environment..."
if ! command -v python3.12 &>/dev/null; then
    abort "Python 3.12 is not installed. Please install it first."
fi

if ! dpkg -s python3.12-venv &>/dev/null; then
    echo "📦 Installing python3.12-venv..."
    sudo apt update && sudo apt install -y python3.12-venv || abort "Failed to install venv package"
fi

python3.12 -m venv venv || abort "Failed to create virtual environment"
source venv/bin/activate || abort "Failed to activate virtual environment"
log "Virtual environment activated"

### 🚀 Install backend and run
echo "📦 Installing the .whl file..."
WHEEL=$(find . -name "*.whl" | head -n 1) || abort "No .whl file found in trulens/"
pip install "$WHEEL" || abort "pip install failed"

echo "🛰️  Starting backend with trulens-app..."
nohup trulens-app > l 8000 ../backend.log 2>&1 &
log "Backend started (log: backend.log)"

### 🌐 Run Frontend
echo "🌐 Checking if 'serve' is installed..."
if ! command -v serve &>/dev/null; then
    echo "📦 Installing 'serve' globally..."
    npm install -g serve || abort "Failed to install serve"
fi

DIST_DIR=$(find . -type d -name dist | head -n 1) || abort "No dist folder found in trulens/"
echo "🖥️  Starting frontend with serve -s $DIST_DIR ..."
nohup serve -s "$DIST_DIR" -l 3000 > ../frontend.log 2>&1 &
log "Frontend started on port 3000 (log: frontend.log)"

log "🎉 All setup complete. Backend and frontend are running."
