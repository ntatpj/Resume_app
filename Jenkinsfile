stage('SonarQube Analysis') {
      environment {
        SONAR_HOST_URL = 'https://your-sonarqube-server.com'
        SONAR_AUTH_TOKEN = credentials('sonarqube-token')
      }
      steps {
        script {
          sh """
          sonar-scanner \
            -Dsonar.projectKey=python-app \
            -Dsonar.sources=. \
            -Dsonar.host.url=${SONAR_HOST_URL} \
            -Dsonar.login=${SONAR_AUTH_TOKEN}
          """
        }
      }
    }
