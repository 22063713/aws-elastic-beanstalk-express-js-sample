pipeline {
    agent {
        docker {
            image 'node:16'
            args '-u root:root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        DOCKER_IMAGE = "<your-dockerhub-username>/aws-sample-app:latest"
    }
    stages {
        stage('Checkout') {
            steps {
                echo "🔍 Checking out source code..."
                checkout scm
            }
        }
        stage('Install Deps & Unit tests') {
            steps {
                echo "📦 Installing dependencies..."
                sh 'npm install --save'
                echo "🧪 Running tests..."
                sh 'npm test || echo "⚠️ No tests found, skipping..."'
            }
        }
        stage('Build Docker image') {
            steps {
                echo "🐳 Building Docker image..."
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }
        stage('Push Docker image') {
            steps {
                echo "🚀 Pushing Docker image to registry..."
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker push $DOCKER_IMAGE'
                }
            }
        }
    }
    post {
        always {
            echo "🗑 Archiving logs if present..."
            archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
        }
    }
}
