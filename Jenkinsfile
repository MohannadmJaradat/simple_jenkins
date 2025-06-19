pipeline {
    agent any
    environment {
        AUTHOR_NAME='Mohannad Jaradat'
        AWS_ACCESS_KEY_ID= credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY_ID= credentials('aws-secret-access-key')
    }
    stages {
        stage("Build") {
            steps {
                echo "Building the app..."
                sh '''
                    echo "Executing df -h"
                    df -h
                    echo "Done executing df -h"
                '''
                echo "The author's name is: ${AUTHOR_NAME}"
            }
        }
        stage("Test") {
            steps {
                echo "Testing the app..."
            }
        }
        stage("Deploy") {
            steps {
                echo "Deploying the app..."
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
        cleanup {
            echo "Cleaning the workspace...."
            cleanWs()
        }
    }
}
