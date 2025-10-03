// ==========================
// CI/CD Pipeline for Project
// Runs inside a Node 16 Docker container and uses a DinD service
// to build & push the application image to Docker Hub.
// ==========================

pipeline {
  // Run all stages inside a container based on Node 16
  agent {
    docker {
      image 'node:16'
      // Give the container access to the DinD daemon and apt
      // - DOCKER_HOST points to your dind service from docker-compose
      // - we run as root to install docker-cli inside the container
      args '-u 0:0 -e DOCKER_HOST=tcp://dind:2375'
    }
  }

  // Simple variables you can change
  environment {
    // Your Docker Hub org/user and repository name for the image
    DOCKERHUB_USER   = 'YOUR_DOCKERHUB_USERNAME'     // <-- change this
    IMAGE_NAME       = 'aws-sample-app'               // <-- change if you want
    // Credentials ID you created in Jenkins (must exist!)
    DOCKERHUB_CREDS_ID = 'dockerhub-creds'
  }

  options {
    // Show timestamps in logs; keep logs readable for the assignment
    timestamps()
  }

  stages {

    stage('Checkout') {
      steps {
        echo '📥 Checking out source code...'
        checkout scm
      }
    }

    stage('Prepare node & docker-cli') {
      steps {
        sh '''
          set -euxo pipefail
          # Update apt catalog inside the Node container and install Docker CLI.
          # (We only need client tools since we talk to daemon at DOCKER_HOST.)
          apt-get update
          apt-get install -y --no-install-recommends docker.io ca-certificates
          docker --version
          node -v
          npm -v
        '''
      }
    }

    stage('Install deps & Unit tests (Node 16)') {
      steps {
        echo '📦 Restoring source and installing dependencies...'
        sh '''
          set -euxo pipefail
          npm install --save

          # If a test script exists in package.json, run tests; otherwise skip.
          if grep -q '"test":' package.json; then
            echo "🧪 Running unit tests..."
            npm test
          else
            echo "ℹ️  No test script found in package.json. Skipping tests."
          fi
        '''
      }
    }

    stage('Build Docker image') {
      steps {
        sh '''
          set -euxo pipefail
          IMAGE_TAG="${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"
          echo "🔧 Building ${IMAGE_TAG}"
          docker build -t "${IMAGE_TAG}" .
          docker images | head -n 10
        '''
      }
    }

    stage('Push Docker image') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDS_ID,
                                         usernameVariable: 'DH_USER',
                                         passwordVariable: 'DH_PASS')]) {
          sh '''
            set -euxo pipefail
            echo "🔐 Logging into Docker Hub…"
            echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin

            IMAGE_TAG="${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"
            LATEST="${DOCKERHUB_USER}/${IMAGE_NAME}:latest"

            echo "🚚 Pushing ${IMAGE_TAG} and ${LATEST}"
            docker tag "${IMAGE_TAG}" "${LATEST}"
            docker push "${IMAGE_TAG}"
            docker push "${LATEST}"

            docker logout || true
          '''
        }
      }
    }
  }

  post {
    always {
      echo '📎 Archiving npm log if present...'
      archiveArtifacts artifacts: 'npm-debug.log', allowEmptyArchive: true
    }
  }
}
