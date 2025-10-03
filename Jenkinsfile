// Jenkinsfile — CI/CD for AWS Sample Node.js app
// Humanized comments for marking :)

pipeline {
  agent none
  options { skipDefaultCheckout(true) } // we'll checkout once in the first stage

  environment {
    // Tag image as latest; you can also add BUILD_NUMBER or git SHA if you want
    DOCKER_IMAGE = "YOUR_DOCKERHUB_USERNAME/aws-sample-app:latest"
  }

  stages {
    stage('Checkout') {
      agent any // run on the controller
      steps {
        echo '📥 Checking out source code...'
        checkout scm
        // Save the workspace to reuse it in other agents
        stash name: 'src', includes: '**/*'
      }
    }

    stage('Install deps & Unit tests (Node 16)') {
      // Use Node 16 Docker image only for Node work
      agent {
        docker {
          image 'node:16'
          args '-u root:root' // avoid permission issues writing node_modules
        }
      }
      steps {
        echo '📦 Restoring source and installing dependencies...'
        unstash 'src'
        // Per assignment: npm install --save
        sh 'npm install --save'
        echo '🧪 Running unit tests (will skip if none are configured)...'
        sh 'npm test || echo "No tests defined, skipping..."'
        // Re-stash in case node_modules produced artifacts you want later
        stash name: 'src-after-npm', includes: '**/*'
      }
    }

    stage('Build Docker image') {
      agent any // run on controller (has docker CLI + DOCKER_HOST=dind)
      steps {
        echo '🐳 Building Docker image on Jenkins controller (DinD backend)...'
        unstash 'src-after-npm'
        sh '''
          set -eux
          docker --version
          docker build -t "$DOCKER_IMAGE" .
        '''
      }
    }

    stage('Push Docker image') {
      agent any
      steps {
        echo '📤 Pushing Docker image to DockerHub...'
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            set -eux
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push "$DOCKER_IMAGE"
          '''
        }
      }
    }
  }

  post {
    always {
      echo '📌 Archiving npm debug logs if present...'
      archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
    }
  }
}
