#!/bin/bash

APP_DIR="/srv/streamlit_app"
REPO_URL="git@github.com:mohannad-jaradat/simple_jenkins.git"
BRANCH=$1

echo "Deploying branch: $BRANCH"

# If folder doesn't exist, clone it
if [ ! -d "$APP_DIR" ]; then
    git clone -b "$BRANCH" "$REPO_URL" "$APP_DIR"
else
    cd "$APP_DIR"
    git pull origin "$BRANCH"
fi

# Install deps and run Streamlit
cd "$APP_DIR"
pip3 install -r requirements.txt
pkill streamlit || true
nohup streamlit run app.py --server.port 8501 > streamlit.log 2>&1 &