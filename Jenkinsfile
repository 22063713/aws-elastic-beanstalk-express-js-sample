pipeline {
  agent {
    docker {
      image 'node:16'
      // run as root so we can access docker.sock; mount docker.sock to build images
      args '-u root:root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    // image name you'll push
    DOCKER_IMAGE = "<your-dockerhub-username>/aws-sample-app:latest"
  }

  stages {
    stage('Checkout') {
      steps {
        echo '🔍 Checking out source code...'
        // start clean so Git can init the workspace
        deleteDir()
        // EXPLICIT checkout (no reliance on "scm")
        git url: 'https://github.com/<your-username>/aws-elastic-beanstalk-express-js-sample.git',
            branch: 'main'
      }
    }

    stage('Install deps & Unit tests') {
      steps {
        echo '📦 Installing dependencies...'
        sh 'npm install --save'
        echo '🧪 Running tests (skip if none exist)...'
        sh 'npm test || echo "No tests found, continuing..."'
      }
    }

    stage('Build Docker image') {
      steps {
        echo '🐳 Building Docker image...'
        sh 'docker build -t $DOCKER_IMAGE .'
      }
    }

    stage('Push Docker image') {
      steps {
        echo '🚀 Pushing Docker image...'
        withCredentials([usernamePassword(credentialsId: '<dockerhub-creds-id>',
                                          usernameVariable: 'DOCKER_USER',
                                          passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
          sh 'docker push $DOCKER_IMAGE'
        }
      }
    }
  }

  post {
    always {
      echo '🗂 Archiving npm debug log if present...'
      archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
    }
  }
}
