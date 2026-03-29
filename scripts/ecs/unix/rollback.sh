#!/bin/bash
set -e

# Uso: ./rollback.sh task-def-bia:2
TASK_ARN=$1

if [ -z "$TASK_ARN" ]; then
  echo "Uso: ./rollback.sh <task-definition:revisao>"
  echo "Exemplo: ./rollback.sh task-def-bia:2"
  exit 1
fi

echo "==> Rollback para: $TASK_ARN"

aws ecs update-service --cluster cluster-bia --service service-bia \
  --task-definition $TASK_ARN --force-new-deployment --region us-east-1 > /dev/null

echo "==> Rollback iniciado"
