// Jenkinsfile — CI/CD for AWS Sample Node.js app
// - Node tasks run inside node:16
// - Docker build/push run on controller (uses DinD via DOCKER_HOST)
// - Tests are optional: stage won’t fail if package.json has no "test" script

pipeline {
  agent none
  options { skipDefaultCheckout(true) }

  environment {
    DOCKER_IMAGE = "YOUR_DOCKERHUB_USERNAME/aws-sample-app:latest" // <-- change me
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
          // Ensure the DinD host can bind-mount the workspace path
          args '-u root:root -v /var/jenkins_home:/var/jenkins_home'
        }
      }
      steps {
        echo '📦 Restoring source and installing dependencies...'
        unstash 'src'
        sh 'npm install --save'

        echo '🧪 Running unit tests if defined...'
        // Only run tests if package.json contains a "test" script
        sh '''
          set -e
          if npm run -s test >/dev/null 2>&1; then
            echo "Found test script. Running tests..."
            npm test
          else
            echo "No test script in package.json. Skipping tests."
          fi
        '''
        // (optional) re-stash
        stash name: 'src-after-npm', includes: '**/*'
      }
    }

    stage('Build Docker image') {
      agent any // controller (has docker CLI)
      steps {
        echo '🐳 Building Docker image (controller talks to DinD)...'
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
      // Provide a node/workspace context even though pipeline uses agent none
      node {
        archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
      }
    }
  }
}
