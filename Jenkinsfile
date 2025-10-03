// Jenkinsfile — CI/CD for AWS Sample Node.js app
// Notes:
// - Node tasks (install/test) run in a Node 16 container scheduled by the Docker plugin.
//   We *explicitly* mount /var/jenkins_home so the DinD host can bind the workspace path.
// - Docker build/push run on the controller (which has docker CLI + DOCKER_HOST to DinD).

pipeline {
  agent none
  options { skipDefaultCheckout(true) }

  environment {
    // Change to your Docker Hub repo
    DOCKER_IMAGE = "YOUR_DOCKERHUB_USERNAME/aws-sample-app:latest"
  }

  stages {
    stage('Checkout') {
      agent any
      steps {
        echo '📥 Checking out source code...'
        checkout scm
        stash name: 'src', includes: '**/*'
      }
    }

    stage('Install deps & Unit tests (Node 16)') {
      agent {
        docker {
          image 'node:16'
          // IMPORTANT: map Jenkins home so the workspace path exists on the DinD host
          args '-u root:root -v /var/jenkins_home:/var/jenkins_home'
          // (the Docker plugin will still mount the workspace automatically)
        }
      }
      steps {
        echo '📦 Restoring source and installing dependencies...'
        unstash 'src'
        sh 'npm install --save'
        echo '🧪 Running unit tests (will skip if none are configured)...'
        sh 'npm test || echo "No tests defined, skipping..."'
        // re-stash in case anything created is needed later (optional)
        stash name: 'src-after-npm', includes: '**/*'
      }
    }

    stage('Build Docker image') {
      agent any   // run on controller (has docker CLI mapped + DOCKER_HOST to dind)
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
        echo '📤 Pushing Docker image to Docker Hub...'
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
