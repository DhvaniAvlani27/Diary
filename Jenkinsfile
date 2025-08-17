pipeline {
    agent any

    environment {
        IMAGE_NAME = "diaryapp"
        IMAGE_TAG = "latest"
        CONTAINER_NAME = "diaryapp-container"
        HOST_PORT = "8081"
        CONTAINER_PORT = "8080"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from Git...'
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                echo 'Building .NET application...'
                sh 'dotnet restore'
                sh 'dotnet build --configuration Release --no-restore'
                sh 'dotnet test --no-build'
                sh 'dotnet publish --configuration Release --output ./publish --no-build'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
                sh 'docker images ${IMAGE_NAME}:${IMAGE_TAG}'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application with Docker Compose...'
                script {
                    // Stop and remove existing containers
                    sh 'docker-compose down || true'
                    
                    // Start services with Docker Compose
                    sh 'docker-compose up -d --build'
                    
                    // Wait for services to be ready
                    sh 'sleep 30'
                    
                    // Verify containers are running
                    sh 'docker-compose ps'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
            echo "Application deployed at: http://localhost:${HOST_PORT}"
        }
        failure {
            echo 'Pipeline failed! Check the logs above for errors.'
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
