#!/bin/bash

APP_DIR="/srv/streamlit_app/simple_jenkins/streamlit_app"
REPO_URL="git@github.com:MohannadmJaradat/simple_jenkins.git"
BRANCH=$1

echo "Deploying branch: $BRANCH"

# If folder doesn't exist, clone it
if [ ! -d "$APP_DIR" ]; then
    git clone -b main git@github.com:MohannadmJaradat/simple_jenkins.git /srv/streamlit_app/simple_jenkins
else
    cd /srv/streamlit_app/simple_jenkins
    git pull origin main
fi

# Install deps and run Streamlit
cd "$APP_DIR"
. venv/bin/activate
pip3 install -r requirements.txt
pkill streamlit || true
nohup streamlit run app.py --server.port 8501 > streamlit.log 2>&1 &