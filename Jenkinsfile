pipeline {
    agent any

    environment {
        IMAGE_NAME = "diaryapp"
        IMAGE_TAG = "dev"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/DhvaniAvlani27/Diary.git'
            }
        }

        stage('Install .NET SDK') {
            steps {
                script {
                    try {
                        def dotnetVersion = sh(script: 'dotnet --version', returnStdout: true).trim()
                        echo "Current .NET version: ${dotnetVersion}"
                    } catch (Exception e) {
                        error """
                        .NET SDK is not installed on this Jenkins server!
                        
                        Please install .NET SDK 8.0 on your Jenkins server:
                        
                        For Ubuntu/Debian:
                        wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
                        sudo dpkg -i packages-microsoft-prod.deb
                        sudo apt-get update
                        sudo apt-get install -y apt-transport-https
                        sudo apt-get install -y dotnet-sdk-8.0
                        
                        For CentOS/RHEL:
                        sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
                        sudo yum install dotnet-sdk-8.0
                        
                        For Amazon Linux:
                        sudo rpm -Uvh https://packages.microsoft.com/config/amazonlinux/2/latest/packages-microsoft-prod.rpm
                        sudo yum install dotnet-sdk-8.0
                        """
                    }
                }
            }
        }

        stage('Restore') {
            steps {
                sh 'dotnet restore DiaryApp.csproj'
            }
        }

        stage('Build') {
            steps {
                sh 'dotnet build DiaryApp.csproj -c Release --no-restore'
            }
        }

        stage('Test') {
            steps {
                sh 'dotnet test --no-build'
            }
        }

        stage('Publish') {
            steps {
                sh 'dotnet publish DiaryApp.csproj -c Release -o out --no-build'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Deploy') {
            steps {
                sh 'docker stop $IMAGE_NAME || true'
                sh 'docker rm $IMAGE_NAME || true'
                sh 'docker run -d --name $IMAGE_NAME -p 8081:8080 $IMAGE_NAME:$IMAGE_TAG'
            }
        }
    }

    post {
        always {
            echo "Pipeline finished!"
        }
        failure {
            echo "Pipeline failed! Check logs."
        }
    }
}
