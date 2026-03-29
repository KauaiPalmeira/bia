#!/bin/bash
set -e

ECR_REGISTRY="211125508089.dkr.ecr.us-east-1.amazonaws.com"
ECR_REPO="bia"
CLUSTER="cluster-bia"
SERVICE="service-bia"
TASK_FAMILY="task-def-bia"
REGION="us-east-1"

COMMIT_HASH=${1:-$(git rev-parse --short=7 HEAD)}
IMAGE_URI="$ECR_REGISTRY/$ECR_REPO:$COMMIT_HASH"

echo "==> Imagem: $IMAGE_URI"

# Build e push com a tag do commit
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
docker build -t $ECR_REPO .
docker tag $ECR_REPO:latest $IMAGE_URI
docker push $IMAGE_URI
docker push $ECR_REGISTRY/$ECR_REPO:latest

# Registra nova task definition trocando apenas a imagem
NEW_TASK_ARN=$(aws ecs register-task-definition --region $REGION \
  --cli-input-json "$(aws ecs describe-task-definition --task-definition $TASK_FAMILY --region $REGION \
    --query '{family:taskDefinition.family,networkMode:taskDefinition.networkMode,executionRoleArn:taskDefinition.executionRoleArn,requiresCompatibilities:taskDefinition.requiresCompatibilities,runtimePlatform:taskDefinition.runtimePlatform,containerDefinitions:taskDefinition.containerDefinitions,volumes:taskDefinition.volumes}' \
    --output json | sed "s|$ECR_REGISTRY/$ECR_REPO:[^\"]*|$IMAGE_URI|g")" \
  --query 'taskDefinition.taskDefinitionArn' --output text)

echo "==> Task definition: $NEW_TASK_ARN"

# Deploy
aws ecs update-service --cluster $CLUSTER --service $SERVICE \
  --task-definition $NEW_TASK_ARN --force-new-deployment --region $REGION > /dev/null

echo "==> Deploy iniciado com $COMMIT_HASH"
