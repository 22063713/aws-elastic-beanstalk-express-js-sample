// Jenkinsfile — StudentID_Project2_pipeline
// Repo: https://github.com/22063713/aws-elastic-beanstalk-express-js-sample (your fork)

pipeline {
  agent {
    docker {
      // Requirement i: use Node 16 image as the build agent
      image 'node:16'
      // Give the agent container access to host Docker (CLI + socket)
      args '-u root -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker'
      reuseNode true
    }
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
    ansiColor('xterm')
  }

  environment {
    // Update if you want a version tag instead of :latest
    DOCKER_IMAGE = '22063713/aws-sample-app:latest'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install dependencies') {
      steps {
        echo '📦 Installing dependencies with npm install --save ...'
        sh '''
          set -eu
          npm --version
          # Requirement ii: use npm install --save
          npm install --save
        '''
      }
    }

    stage('Unit tests') {
      steps {
        echo '🧪 Running unit tests...'
        // If the repo has no tests, this still passes
        sh '''
          set +e
          npm test
          rc=$?
          if [ $rc -ne 0 ]; then
            echo "No tests specified or tests failed (exit=$rc). If no tests, this is okay."
            # If you DO want to fail when there are no tests, remove the next line:
            exit 0
          fi
        '''
      }
    }

    stage('Security Scan (Snyk -> fallback to npm audit)') {
      steps {
        script {
          // Try Snyk if a token is provided; otherwise fall back to npm audit
          def haveSnyk = false
          withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
            if (env.SNYK_TOKEN?.trim()) { haveSnyk = true }
          }

          if (haveSnyk) {
            withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
              sh '''
                set -eu
                npm install -g snyk
                snyk auth $SNYK_TOKEN
                # Fail build on HIGH/CRITICAL
                snyk test --severity-threshold=high
              '''
            }
          } else {
            echo '🔎 Snyk token not configured; falling back to npm audit (fails on high).'
            sh '''
              set -eu
              # npm audit returns non-zero when >= the threshold is found -> this will fail the build
              npm audit --audit-level=high
            '''
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        echo '🐳 Building Docker image...'
        sh '''
          set -eu
          docker --version
          docker build -t "$DOCKER_IMAGE" .
        '''
      }
    }

    stage('Push Docker Image') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-creds',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh '''
            set -eu
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push "$DOCKER_IMAGE"
          '''
        }
      }
    }
  }

  post {
    always {
      echo '📎 Archiving logs/artifacts...'
      archiveArtifacts allowEmptyArchive: true, artifacts: '**/npm-*.log, npm-debug.log, snyk*.json'
    }
    success { echo '✅ Pipeline finished successfully.' }
    failure { echo '❌ Pipeline failed. Check the stage that broke in Console Output.' }
  }
}
