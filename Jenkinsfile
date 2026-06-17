pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'anthonyquiroz/agenda-app:latest'
        CONTAINER_NAME = 'agenda-app-container'
    }

    stages {
        stage('Checkout') {
            steps {
                // Downloads code from the git repository defined in the Jenkins job
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                echo 'Running flutter pub get, tests with coverage, and building web release...'
                sh 'flutter pub get'
                sh 'flutter test --coverage'
                sh 'dart pub global activate flutter_coverage_report'
                sh 'dart pub global run flutter_coverage_report:fcr coverage/lcov.info'
                sh 'flutter build web --release'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                // Performs SonarQube static code analysis for Dart and reports unit test coverage
                echo 'Running SonarQube static analysis...'
                withSonarQubeEnv('sonarqube') {
                    sh 'sonar-scanner -Dsonar.projectKey=agenda-app -Dsonar.sources=lib -Dsonar.tests=test -Dsonar.dart.lcov.reportPath=coverage/lcov.info'
                }
            }
        }

        stage('Docker Build & Deploy') {
            steps {
                echo 'Building Docker image and deploying Nginx container...'
                sh "docker build -t ${DOCKER_IMAGE} ."
                // Stops and deletes any existing container of the app to avoid port conflicts
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
                // Run the new container, exposing the web app on port 8082
                sh "docker run -d -p 8082:80 --name ${CONTAINER_NAME} ${DOCKER_IMAGE}"
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully! App is deployed and running on http://localhost:8082'
        }
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
    }
}
