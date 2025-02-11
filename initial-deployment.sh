#!/bin/bash

# Check if DOCKERHUB_USERNAME and DOCKERHUB_PASSWORD are set
if [ -z "${DOCKERHUB_USERNAME}" ] || [ -z "${DOCKERHUB_PASSWORD}" ]; then
    echo "Error: DOCKERHUB_USERNAME and/or DOCKERHUB_PASSWORD environment variables are not set"
    echo "Please set them first:"
    echo "export DOCKERHUB_USERNAME=your-dockerhub-username"
    echo "export DOCKERHUB_PASSWORD=your-dockerhub-password"
    exit 1
fi

# Build the Docker image
echo "Building Docker image..."
docker build -t ${DOCKERHUB_USERNAME}/blue-green-app:1 .

# Log in to Docker Hub
echo "Logging in to Docker Hub..."
echo "${DOCKERHUB_PASSWORD}" | docker login -u ${DOCKERHUB_USERNAME} --password-stdin

# Push the image to Docker Hub
echo "Pushing image to Docker Hub..."
docker push ${DOCKERHUB_USERNAME}/blue-green-app:1

# Check if minikube is running
if ! minikube status | grep -q "Running"; then
    echo "Starting Minikube..."
    minikube start
else
    echo "Minikube is already running"
fi

APP_MANIFESTS_PATH="manifests/app"

# Create temporary deployment file with replaced username
echo "Preparing deployment files..."
sed "s|\${DOCKERHUB_USERNAME}|${DOCKERHUB_USERNAME}|g" $APP_MANIFESTS_PATH/app-deployment.yaml > app-deployment-temp.yaml

# Deploy initial application
echo "Deploying initial application..."
kubectl apply -f app-deployment-temp.yaml -n default
kubectl apply -f $APP_MANIFESTS_PATH/app-service.yaml -n default

# Clean up temporary file
rm app-deployment-temp.yaml

echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available deployment/app-deployment -n default --timeout=300s

# Get access URL
NODE_IP=$(minikube ip)
NODE_PORT=$(kubectl get svc app-service -o jsonpath='{.spec.ports[0].nodePort}')
echo "Application is available at: http://${NODE_IP}:${NODE_PORT}"

# Unset environment variables
unset DOCKERHUB_USERNAME DOCKERHUB_PASSWORD

# Log out from Docker Hub
docker logout