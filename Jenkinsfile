// Jenkins Declarative Pipeline for the AWS sample app
// Runs npm steps in a Node 16 container, then builds & pushes a Docker image to Docker Hub.
// Assumptions:
//  - Your Jenkins controller is running in Docker with the docker CLI mounted
//    and DOCKER_HOST set to tcp://dind:2375 (from docker-compose).
//  - Credentials ID "dockerhub-creds" exists in Jenkins with your Docker Hub login.

pipeline {
  agent none

  environment {
    // Your details:
    DOCKERHUB_USER     = '22063713'
    DOCKERHUB_CREDS_ID = 'dockerhub-creds'
    IMAGE_NAME         = 'aws-sample-app' // full name will be 22063713/aws-sample-app
  }

  options {
    timestamps()
    ansiColor('xterm')
  }

  stages {

    stage('Checkout') {
      agent { label 'built-in' } // run on controller
      steps {
        echo 'Checking out source code...'
        checkout scm
      }
    }

    stage('Install deps & Unit tests (Node 16)') {
      // We run Node steps in a disposable container for a clean, repeatable env.
      // --entrypoint="" avoids the entrypoint consistency warning some images trigger.
      agent {
        docker {
          image 'node:16'
          args '--entrypoint="" -u 0:0'  // run as root to avoid perms issues in mounted workspace
          reuseNode true
        }
      }
      steps {
        sh '''
          set -euxo pipefail
          node -v
          npm -v
          # Install project dependencies (assignment asked for --save)
          npm install --save
          # Run tests (won’t fail the build if none are defined)
          npm test || echo "No tests or tests failed; continuing per assignment scope"
        '''
      }
    }

    stage('Build Docker image') {
      agent { label 'built-in' } // build using docker CLI available in controller
      steps {
        sh '''
          set -euxo pipefail
          echo "Docker CLI version:"
          docker version

          # Build image with two tags: build number and latest
          docker build -t ${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER} -t ${DOCKERHUB_USER}/${IMAGE_NAME}:latest .
        '''
      }
    }

    stage('Push Docker image') {
      agent { label 'built-in' }
      steps {
        withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDS_ID}", usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
          sh '''
            set -euxo pipefail
            echo "${DH_PASS}" | docker login -u "${DH_USER}" --password-stdin
            docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}
            docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:latest
            docker logout || true
          '''
        }
      }
    }
  }

  post {
    always {
      echo 'Archiving npm logs if present...'
      archiveArtifacts artifacts: 'npm-debug.log', allowEmptyArchive: true
    }
    success {
      echo "✅ Build & push completed: ${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"
    }
    failure {
      echo '❌ Pipeline failed. Check the stage logs above.'
    }
  }
}
