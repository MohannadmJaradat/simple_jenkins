#!/bin/bash

set -e  # Exit on error
set -o pipefail

APP_BASE="/srv/streamlit_app"
REPO_URL="git@github.com:mohannad-jaradat/simple_jenkins.git"
BRANCH="${1:-main}"  # Use first arg or default to 'main'

APP_DIR="$APP_BASE/simple_jenkins/streamlit_app"

echo "🚀 Deploying branch: $BRANCH"

# Clone repo if not present
if [ ! -d "$APP_BASE/simple_jenkins/.git" ]; then
    echo "📦 Cloning repository..."
    git clone -b "$BRANCH" "$REPO_URL" "$APP_BASE/simple_jenkins"
else
    echo "🔄 Pulling latest changes..."
    cd "$APP_BASE/simple_jenkins"
    git fetch origin
    git checkout "$BRANCH"
    git reset --hard "origin/$BRANCH"
fi

# Go to app directory
cd "$APP_DIR"

# Set up Python environment
echo "🐍 Setting up Python environment..."
python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Restart Streamlit
echo "🚦 Restarting Streamlit app..."
pkill streamlit || true
nohup streamlit run app.py \
    --server.port 8501 \
    --server.address 3.83.229.104 \
    --server.enableCORS false \
    > streamlit.log 2>&1 &

echo "✅ Deployment finished! App running at: http://<your-server-ip>:8501"
