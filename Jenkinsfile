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
        stage("Build") {
            steps {
                echo "Building the app..."
                sh '''
                    python3 -m venv venv
                    source venv/bin/activate
                    pip install -r requirements.txt
                '''
                echo "The author's name is: ${AUTHOR_NAME}"
            }
        }
        stage("Test") {
            steps {
                sh '''
                    source venv/bin/activate
                    pytest
                '''
            }
        }
        stage("Deploy") {
            steps {
                sh '''
                    echo "Deploying branch: ${DEPLOY_BRANCH} locally..."
                    bash /srv/streamlit_app/simple_jenkins/streamlit_app/deploy.sh ${DEPLOY_BRANCH}
                '''
            }
        }
    }
    post{
        always {
            echo "This will always run regardless of the completion status"
        }
        success {
            echo "This will run if the build succeeded"
            mail to: 'mohannad.jaradat@cirrusgo.com',
            subject: "✅ Build Successful: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "The build was successful.\n\nSee: ${env.BUILD_URL}"
        }
        failure {
            echo "This will run if the job failed"
            mail to: 'mohannad.jaradat@cirrusgo.com',
            subject: "❌ Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "The build has failed.\n\nCheck the console: ${env.BUILD_URL}"
        }
        unstable {
            echo "This will run if the completion status was 'unstable', usually by test failures"
        }
        changed {
            echo "This will run if the state of the pipeline has changed"
            echo "For example, if the previous run failed but is now successful"
        }
        fixed {
            echo "This will run if the previous run failed or unstable and now is successful"
        }
    }
}
