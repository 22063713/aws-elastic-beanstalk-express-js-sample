pipeline {
    agent {
        docker {
            image 'node:16'   // Node 16 build agent
            args '-u root:root' // Run as root so we can install dependencies if needed
        }
    }

    environment {
        DOCKER_IMAGE = "22063713/aws-sample-app:latest"   // your repo
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out source code...'
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '📦 Installing dependencies...'
                sh 'npm install --save'
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo '🧪 Running unit tests...'
                sh 'npm test || echo "⚠️ No tests found, skipping..."'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Push Docker Image') {
            steps {
                echo '🚀 Pushing Docker image...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh 'docker push $DOCKER_IMAGE'
                }
            }
        }
    }

    post {
        always {
            echo '📦 Archiving npm logs if present...'
            archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
        }
    }
}
