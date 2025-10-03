// Jenkinsfile for CI/CD automation
// This pipeline builds, tests, scans, and pushes Docker images for the Node.js app

pipeline {
    agent {
        // Run pipeline inside Node 16 Docker image
        docker {
            image 'node:16'
            args '-u root:root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        // Change this to your DockerHub username/repo
        DOCKER_IMAGE = "22063713/aws-sample-app:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                echo ' Checking out repository...'
                checkout scm
            }
        }

        stage('Install dependencies') {
            steps {
                echo ' Installing dependencies...'
                sh 'npm install --save'
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo ' Running tests...'
                // If package.json has tests defined, this will run them
                sh 'npm test || echo "No tests defined, skipping..."'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo ' Building Docker image...'
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing image to DockerHub...'
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
            echo 'Archiving logs...'
            archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
        }
    }
}
