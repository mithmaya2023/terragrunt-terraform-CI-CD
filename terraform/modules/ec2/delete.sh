#!/bin/bash

# Fetch AWS Account ID
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Set resource names
export ECS_CLUSTER_NAME="ai-cluster"
export ECS_SERVICE_NAME="ai-text-service"
export TASK_FAMILY="ai-text-task"
export ECR_REPO_NAME="ai-text-app"
export EXECUTION_ROLE_NAME="ecsTaskExecutionRole"

# Fetch Task Definition ARN
export TASK_DEFINITION_ARN=$(aws ecs list-task-definitions --family-prefix $TASK_FAMILY --query "taskDefinitionArns[-1]" --output text)

# Fetch Running Task ARN
export TASK_ARN=$(aws ecs list-tasks --cluster $ECS_CLUSTER_NAME --query "taskArns[-1]" --output text)

# Fetch Security Group ID
export SECURITY_GROUP_ID=$(aws ecs describe-services --cluster $ECS_CLUSTER_NAME --services $ECS_SERVICE_NAME --query "services[0].networkConfiguration.awsvpcConfiguration.securityGroups[0]" --output text)

# Fetch Subnet IDs
export SUBNET_IDS=$(aws ecs describe-services --cluster $ECS_CLUSTER_NAME --services $ECS_SERVICE_NAME --query "services[0].networkConfiguration.awsvpcConfiguration.subnets" --output text | tr '\t' ',')

echo "### Deleting ECS Service..."
aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --desired-count 0 --region us-west-2
aws ecs delete-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --force --region us-west-2

echo "### Deregistering Task Definition..."
if [ "$TASK_DEFINITION_ARN" != "None" ]; then
    aws ecs deregister-task-definition --task-definition $TASK_DEFINITION_ARN --region us-west-2
else
    echo "No task definition found to deregister."
fi

echo "### Stopping Running Tasks..."
if [ "$TASK_ARN" != "None" ]; then
    aws ecs stop-task --cluster $ECS_CLUSTER_NAME --task $TASK_ARN --region us-west-2
else
    echo "No running task found to stop."
fi

echo "### Deleting ECS Cluster..."
aws ecs delete-cluster --cluster $ECS_CLUSTER_NAME --region us-west-2

echo "### Deleting ECR Repository..."
aws ecr delete-repository --repository-name $ECR_REPO_NAME --force --region us-west-2

echo "### Deleting Security Group (if not in use)..."
if [ "$SECURITY_GROUP_ID" != "None" ]; then
    aws ec2 delete-security-group --group-id $SECURITY_GROUP_ID --region us-west-2 || echo "Security group still in use."
else
    echo "No security group found to delete."
fi


echo "### Cleanup Completed!"

