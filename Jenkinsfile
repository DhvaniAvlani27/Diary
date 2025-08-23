pipeline {
    agent {
        docker {
            image 'mcr.microsoft.com/dotnet/sdk:8.0'
            args '-u root:root' // run as root so it can use docker if needed
        }
    }

    environment {
        IMAGE_NAME = "diaryapp"
        IMAGE_TAG = "latest"
        CONTAINER_NAME = "diaryapp-container"
        HOST_PORT = "8081"
        CONTAINER_PORT = "8080"
        DOCKER_NETWORK = "diaryapp_diary-network"
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
<<<<<<< HEAD
                echo 'Building .NET 8 application...'
                sh "dotnet --version"
=======
                echo 'Building .NET application...'
>>>>>>> 9fdd647df8acb80d4c88b716ebcdc34ca0d0d1e3
                sh "dotnet restore"
                sh "dotnet build --configuration Release --no-restore"
                sh "dotnet test --no-build"
                sh "dotnet publish --configuration Release --output ./publish --no-build"
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker images ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                script {
<<<<<<< HEAD
                    sh "docker network create ${DOCKER_NETWORK} || true"

                    sh "docker stop ${CONTAINER_NAME} || true"
                    sh "docker rm ${CONTAINER_NAME} || true"
                    
                    sh "docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} --network ${DOCKER_NETWORK} ${IMAGE_NAME}:${IMAGE_TAG}"
                    
=======
                    // Ensure network exists
                    sh "docker network create ${DOCKER_NETWORK} || true"

                    // Stop and remove existing container if it exists
                    sh "docker stop ${CONTAINER_NAME} || true"
                    sh "docker rm ${CONTAINER_NAME} || true"
                    
                    // Run new container
                    sh "docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} --network ${DOCKER_NETWORK} ${IMAGE_NAME}:${IMAGE_TAG}"
                    
                    // Verify container is running
>>>>>>> 9fdd647df8acb80d4c88b716ebcdc34ca0d0d1e3
                    sh "docker ps | grep ${CONTAINER_NAME}"
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
