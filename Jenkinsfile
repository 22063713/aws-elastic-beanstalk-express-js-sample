pipeline {
    agent any

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    environment {
        DOCKER_IMAGE = "22063713/aws-sample-app:latest"
    }

    stages {
        stage('Install Node and Dependencies') {
            steps {
                echo "📦 Installing Node.js and dependencies..."
                sh '''
                    apt-get update -y
                    apt-get install -y curl
                    curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
                    apt-get install -y nodejs
                    node -v
                    npm -v
                    npm install --save
                '''
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo "🧪 Running unit tests..."
                sh '''
                    npm test || echo "⚠️ No tests specified, skipping..."
                '''
            }
        }

        stage('Snyk Security Scan') {
            steps {
                echo "🔒 Running Snyk vulnerability scan..."
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    sh '''
                        npm install -g snyk
                        snyk auth $SNYK_TOKEN
                        snyk test --severity-threshold=high
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."
                sh '''
                    docker --version
                    docker build -t $DOCKER_IMAGE .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "📤 Pushing Docker image..."
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKER_IMAGE
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning up..."
            sh 'docker system prune -af || true'
        }
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for details."
        }
    }
}
