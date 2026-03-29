#!/bin/bash

TASK_FAMILY="task-def-bia"
CLUSTER="cluster-bia"
SERVICE="service-bia"
REGION="us-east-1"

CURRENT=$(aws ecs describe-services --cluster $CLUSTER --services $SERVICE --region $REGION \
  --query 'services[0].taskDefinition' --output text)

echo "Versão atual em produção: $CURRENT"
echo ""
echo "Revisões disponíveis para rollback:"

aws ecs list-task-definitions --family-prefix $TASK_FAMILY --region $REGION \
  --query 'taskDefinitionArns[]' --output text | tr '\t' '\n' | while read ARN; do
  REV=$(echo $ARN | grep -o '[0-9]*$')
  IMAGE=$(aws ecs describe-task-definition --task-definition $ARN --region $REGION \
    --query 'taskDefinition.containerDefinitions[0].image' --output text)
  if [ "$ARN" = "$CURRENT" ]; then
    echo "  $TASK_FAMILY:$REV  ->  $IMAGE  [ATUAL]"
  else
    echo "  $TASK_FAMILY:$REV  ->  $IMAGE"
  fi
done
