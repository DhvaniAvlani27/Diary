#!/bin/bash

# Simple deployment script for DiaryApp
# Usage: ./deploy.sh

set -e  # Exit on any error

echo "🚀 Starting DiaryApp deployment..."

# Configuration
IMAGE_NAME="diaryapp"
IMAGE_TAG="latest"
CONTAINER_NAME="diaryapp-container"
HOST_PORT="8081"
CONTAINER_PORT="8080"

echo "📦 Building Docker image..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

echo "🔄 Stopping existing container..."
docker stop ${CONTAINER_NAME} 2>/dev/null || true
docker rm ${CONTAINER_NAME} 2>/dev/null || true

echo "🚀 Starting new container..."
docker run -d \
    --name ${CONTAINER_NAME} \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    ${IMAGE_NAME}:${IMAGE_TAG}

echo "✅ Deployment completed successfully!"
echo "🌐 Application is running at: http://localhost:${HOST_PORT}"
echo "📊 Container status:"
docker ps | grep ${CONTAINER_NAME}

echo "📝 To view logs: docker logs ${CONTAINER_NAME}"
echo "🛑 To stop: docker stop ${CONTAINER_NAME}"
