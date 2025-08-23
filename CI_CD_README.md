# CI/CD Pipeline Setup Guide

## Overview
This guide explains how to set up a simple CI/CD pipeline for the DiaryApp using Jenkins and Docker.

## Prerequisites

### Jenkins Server Requirements
- Ubuntu/Debian server (recommended)
- Jenkins installed and running
- Docker installed
- .NET SDK 8.0 installed

## Installation Steps

### 1. Install .NET SDK on Jenkins Server
```bash
# Download Microsoft package repository
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

# Update and install .NET SDK
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0

# Verify installation
dotnet --version
```

### 2. Install Docker on Jenkins Server
```bash
# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io

# Add Jenkins user to docker group
sudo usermod -aG docker jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# Verify Docker installation
docker --version
```

### 3. Configure Jenkins Pipeline
1. Create a new Jenkins job
2. Select "Pipeline" job type
3. Configure Git repository: `https://github.com/DhvaniAvlani27/Diary.git`
4. Set branch to `main`
5. Pipeline script from SCM: Select Git
6. Script path: `DiaryApp/Jenkinsfile`

## Pipeline Stages

### 1. Checkout
- Clones code from Git repository

### 2. Build & Test
- Restores NuGet packages
- Builds application in Release mode
- Runs unit tests
- Publishes application

### 3. Build Docker Image
- Creates Docker image from published application
- Tags image as `diaryapp:latest`

### 4. Deploy
- Stops existing container (if any)
- Removes old container
- Starts new container
- Maps port 8081 (host) to 8080 (container)

## Manual Deployment

### Using the deployment script:
```bash
cd DiaryApp
chmod +x deploy.sh
./deploy.sh
```

### Using Docker commands:
```bash
# Build image
docker build -t diaryapp:latest .

# Run container
docker run -d --name diaryapp-container -p 8081:8080 diaryapp:latest
```

## Accessing the Application

- **URL**: http://localhost:8081
- **Container Port**: 8080 (internal)
- **Host Port**: 8081 (external)

## Useful Commands

### View running containers:
```bash
docker ps
```

### View container logs:
```bash
docker logs diaryapp-container
```

### Stop application:
```bash
docker stop diaryapp-container
```

### Remove container:
```bash
docker rm diaryapp-container
```

### View Docker images:
```bash
docker images
```

## Troubleshooting

### Common Issues:

1. **"dotnet: not found"**
   - Install .NET SDK on Jenkins server

2. **"docker: not found"**
   - Install Docker on Jenkins server

3. **Permission denied for Docker**
   - Add Jenkins user to docker group and restart Jenkins

4. **Port already in use**
   - Change HOST_PORT in Jenkinsfile or stop existing container

### Check Jenkins logs:
```bash
sudo tail -f /var/log/jenkins/jenkins.log
```

## Pipeline Benefits

✅ **Automated**: No manual deployment needed  
✅ **Consistent**: Same deployment process every time  
✅ **Reversible**: Easy to rollback to previous version  
✅ **Scalable**: Easy to add more stages or environments  
✅ **Visible**: Clear pipeline progress and status  

## Next Steps

1. Set up production database connection string
2. Add environment-specific configurations
3. Implement blue-green deployment
4. Add monitoring and alerting
5. Set up backup and recovery procedures
