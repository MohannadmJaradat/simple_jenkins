pipeline {
    agent any
    environment {
        AUTHOR_NAME='Mohannad Jaradat'
        AWS_ACCESS_KEY_ID= credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY_ID= credentials('aws-secret-access-key')
        DEPLOY_BRANCH = "main"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Pull Repo') {
            steps {
                echo "📥 Pulling latest changes from branch: ${DEPLOY_BRANCH}"
                sh '''
                    APP_BASE="/srv/streamlit_app"
                    REPO_URL="git@github.com:MohannadmJaradat/simple_jenkins.git"
                    BRANCH="${DEPLOY_BRANCH}"

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
                '''
            }
        }
        stage("Lint") {
            steps {
                sh '''
                    . venv/bin/activate
                    flake8 /srv/streamlit_app/simple_jenkins/streamlit_app/app.py > lint_report.txt || true
                '''
                archiveArtifacts artifacts: 'lint_report.txt'
            }
        }
        stage("Build") {
            steps {
                echo "Building the app..."
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r /srv/streamlit_app/simple_jenkins/streamlit_app/requirements.txt
                    tar -czf app.tar.gz /srv/streamlit_app/simple_jenkins/
                '''
                archiveArtifacts 'app.tar.gz'
                echo "The author's name is: ${AUTHOR_NAME}"
            }
        }
        stage("Test") {
            steps {
                sh '''
                    . venv/bin/activate
                    pytest --cov=. > coverage.txt
                '''
                archiveArtifacts artifacts: 'coverage.txt'
            }
        }
        stage("Deploy") {
            steps {
                sh '''
                    chmod +x /srv/streamlit_app/simple_jenkins/streamlit_app/deploy.sh
                    echo "Deploying branch: ${DEPLOY_BRANCH} locally..."
                    bash /srv/streamlit_app/simple_jenkins/streamlit_app/deploy.sh ${DEPLOY_BRANCH}
                '''
            }
        }
        stage('Deploy to Remote Server') {// This is an optional stage in case you want to deploy the streamlit app on a separate server
            environment {
                REMOTE_USER = 'ubuntu' // or ec2-user, jenkins, etc.
                REMOTE_IP = '172.31.23.76'
                REMOTE_PATH = '/srv/streamlit/streamlit_app/simple_jenkins/'
                REMOTE_DEPLOY_SCRIPT = '/srv/streamlit/streamlit_app/simple_jenkins/streamlit_app/deploy.sh'
            }
            steps {
                sshagent(credentials: ['app-server-key']) {
                    sh '''
                        echo "📁 Ensuring remote path exists..."
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_IP} "sudo mkdir -p ${REMOTE_PATH}"

                        echo "📤 Copying files to remote server..."
                        scp -o StrictHostKeyChecking=no -r /srv/streamlit_app/simple_jenkins/* ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_PATH}

                        echo "🚀 Executing deploy.sh on remote server..."
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_IP} "chmod +x ${REMOTE_DEPLOY_SCRIPT} && bash ${REMOTE_DEPLOY_SCRIPT}"
                    '''
                }
            }
        }
    }
    post {
        always {
            echo "This will always run regardless of the completion status"
            mail to: 'jaradatm2@hotmail.com',
            subject: "📦 Pipeline Completed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "The pipeline has completed (success, failure, or otherwise).\n\nSee: ${env.BUILD_URL}"
        }
        success {
            echo "This will run if the build succeeded"
            mail to: 'jaradatm2@hotmail.com',
            subject: "✅ Build Successful: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "The build was successful.\n\nSee: ${env.BUILD_URL}"
        }
        failure {
            echo "This will run if the job failed"
            mail to: 'jaradatm2@hotmail.com',
            subject: "❌ Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "The build has failed.\n\nCheck the console: ${env.BUILD_URL}"
        }
        unstable {
            echo "This will run if the completion status was 'unstable', usually by test failures"
            mail to: 'jaradatm2@hotmail.com',
            subject: "⚠️ Build Unstable: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "The build is unstable, usually due to test failures.\n\nSee: ${env.BUILD_URL}"
        }
        changed {
            echo "This will run if the state of the pipeline has changed"
            echo "For example, if the previous run failed but is now successful"
            mail to: 'jaradatm2@hotmail.com',
            subject: "🔁 Pipeline State Changed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "The build status has changed from the last run (e.g., failed to passed).\n\nSee: ${env.BUILD_URL}"
        }
        fixed {
            echo "This will run if the previous run failed or unstable and now is successful"
            mail to: 'jaradatm2@hotmail.com',
            subject: "🔧 Build Fixed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "The build is now successful after previously failing or being unstable.\n\nSee: ${env.BUILD_URL}"
        }
        // cleanup {
        //     echo "🧹 Cleaning the workspace...."
        //     cleanWs()
        // }
    }

}
