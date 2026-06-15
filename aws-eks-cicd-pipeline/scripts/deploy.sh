#!/bin/bash
# ============================================
# Deploy Application to AWS EKS
# ============================================

set -euo pipefail

# Variables
AWS_REGION="${AWS_REGION:ap-south-1}"
EKS_CLUSTER="${EKS_CLUSTER:-my-eks-cluster}"
K8S_NAMESPACE="${K8S_NAMESPACE:-production}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_REPO="aws-eks-cicd-demo"
DOCKER_IMAGE="${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"

echo "============================================"
echo "🚀 Deploying to AWS EKS"
echo "============================================"
echo "Region:      ${AWS_REGION}"
echo "Cluster:     ${EKS_CLUSTER}"
echo "Namespace:   ${K8S_NAMESPACE}"
echo "Image:       ${DOCKER_IMAGE}"
echo "============================================"

# Step 1: Update kubeconfig
echo "📋 Updating kubeconfig..."
aws eks update-kubeconfig \
    --name "${EKS_CLUSTER}" \
    --region "${AWS_REGION}"

# Step 2: Update image in deployment manifest
echo "🔄 Updating deployment manifest..."
sed -i "s|IMAGE_PLACEHOLDER|${DOCKER_IMAGE}|g" k8s/deployment.yaml

# Step 3: Apply Kubernetes manifests
echo "☸️ Applying Kubernetes manifests..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/hpa.yaml

# Step 4: Wait for rollout
echo "⏳ Waiting for rollout to complete..."
kubectl rollout status deployment/eks-cicd-demo \
    -n "${K8S_NAMESPACE}" --timeout=300s

# Step 5: Verify
echo "✅ Deployment verification..."
kubectl get pods -n "${K8S_NAMESPACE}" -l app=eks-cicd-demo
kubectl get svc -n "${K8S_NAMESPACE}" -l app=eks-cicd-demo

echo "============================================"
echo "🎉 Deployment completed successfully!"
echo "============================================"
