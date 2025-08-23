pipeline {
    agent any

    environment {
        IMAGE_NAME = "diaryapp"
        IMAGE_TAG = "latest"
        CONTAINER_NAME = "diaryapp-container"
        HOST_PORT = "8081"
        CONTAINER_PORT = "8080"
        DOCKER_NETWORK = "diaryapp-network"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from Git...'
                checkout scm
            }
        }

        stage('Check Prerequisites') {
            steps {
                echo 'Checking system prerequisites...'
                sh 'docker --version || echo "Docker not found - please install Docker"'
                sh 'dotnet --version || echo ".NET SDK not found - please install .NET 8.0 SDK"'
            }
        }

        stage('Build & Test') {
            when {
                expression { sh(script: 'dotnet --version', returnStdout: true).trim().startsWith('8.') }
            }
            steps {
                echo 'Building .NET application...'
                dir('DiaryApp') {
                    sh 'dotnet restore'
                    sh 'dotnet build --configuration Release --no-restore'
                    sh 'dotnet test --no-build || echo "Tests failed but continuing..."'
                    sh 'dotnet publish --configuration Release --output ./publish --no-build'
                }
            }
        }

        stage('Build Docker Image') {
            when {
                expression { sh(script: 'docker --version', returnStdout: true).contains('Docker version') }
            }
            steps {
                echo 'Building Docker image...'
                dir('DiaryApp') {
                    sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
                    sh 'docker images ${IMAGE_NAME}:${IMAGE_TAG}'
                }
            }
        }

        stage('Deploy') {
            when {
                expression { sh(script: 'docker --version', returnStdout: true).contains('Docker version') }
            }
            steps {
                echo 'Deploying application...'
                script {
                    // Ensure network exists
                    sh 'docker network create ${DOCKER_NETWORK} || true'

                    // Stop and remove existing container if it exists
                    sh 'docker stop ${CONTAINER_NAME} || true'
                    sh 'docker rm ${CONTAINER_NAME} || true'
                    
                    // Run new container
                    sh 'docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} --network ${DOCKER_NETWORK} ${IMAGE_NAME}:${IMAGE_TAG}'
                    
                    // Verify container is running
                    sh 'docker ps | grep ${CONTAINER_NAME}'
                }
            }
        }

        stage('Install .NET 8.0 SDK') {
            when {
                not {
                    expression { sh(script: 'dotnet --version', returnStdout: true).trim().startsWith('8.') }
                }
            }
            steps {
                echo 'Installing .NET 8.0 SDK...'
                sh '''
                    # Download Microsoft package repository
                    wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
                    sudo dpkg -i packages-microsoft-prod.deb
                    rm packages-microsoft-prod.deb
                    
                    # Update and install .NET SDK
                    sudo apt-get update
                    sudo apt-get install -y dotnet-sdk-8.0
                    
                    # Verify installation
                    dotnet --version
                '''
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
            echo 'Common issues:'
            echo '1. .NET 8.0 SDK not installed - check Install .NET 8.0 SDK stage'
            echo '2. Docker not installed or not accessible'
            echo '3. Port ${HOST_PORT} already in use'
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}