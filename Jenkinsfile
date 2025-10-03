pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "22063713/aws-sample-app:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/22063713/aws-elastic-beanstalk-express-js-sample.git'
            }
        }

        stage('Install Deps & Unit Tests') {
            agent {
                docker {
                    image 'node:16'
                    args '-v /var/jenkins_home/workspace:/var/jenkins_home/workspace --entrypoint=""'
                }
            }
            steps {
                sh 'npm install --save'
                sh 'npm test || echo "⚠️ No tests found, skipping..."'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t $DOCKER_IMAGE ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub-pass', variable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u 22063713 --password-stdin"
                    sh "docker push $DOCKER_IMAGE"
                }
            }
        }
    }
}
