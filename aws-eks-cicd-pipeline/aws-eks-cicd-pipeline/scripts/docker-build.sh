#!/bin/bash
# ============================================
# Build and Push Docker Image to AWS ECR
# ============================================

set -euo pipefail

# Variables
AWS_REGION="${AWS_REGION:-us-east-1}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_REPO="aws-eks-cicd-demo"
DOCKER_IMAGE="${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"

echo "============================================"
echo "🐳 Building Docker Image"
echo "============================================"
echo "Image: ${DOCKER_IMAGE}"
echo "============================================"

# Step 1: Login to ECR
echo "🔑 Logging in to AWS ECR..."
aws ecr get-login-password --region "${AWS_REGION}" | \
    docker login --username AWS --password-stdin "${ECR_REGISTRY}"

# Step 2: Create ECR repository (if not exists)
echo "📦 Creating ECR repository (if not exists)..."
aws ecr describe-repositories --repository-names "${ECR_REPO}" --region "${AWS_REGION}" 2>/dev/null || \
    aws ecr create-repository --repository-name "${ECR_REPO}" --region "${AWS_REGION}"

# Step 3: Build Docker image
echo "🔨 Building Docker image..."
cd app
docker build -t "${DOCKER_IMAGE}" .
docker tag "${DOCKER_IMAGE}" "${ECR_REGISTRY}/${ECR_REPO}:latest"

# Step 4: Push to ECR
echo "🚀 Pushing to ECR..."
docker push "${DOCKER_IMAGE}"
docker push "${ECR_REGISTRY}/${ECR_REPO}:latest"

echo "============================================"
echo "✅ Docker image pushed successfully!"
echo "Image: ${DOCKER_IMAGE}"
echo "============================================"
