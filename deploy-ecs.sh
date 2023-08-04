#!/bin/bash

# Define variables for each microservice
COMMON_SERVICE="quarkusshop-common"
CUSTOMER_SERVICE="quarkushop-customer"
ORDER_SERVICE="quarkusshop-order"
PRODUCT_SERVICE="quarkusshop-product"
USER_SERVICE="quarkusshop-user"
CLUSTER_NAME="your-ecs-cluster-name"
NEW_IMAGE_VERSION="your-new-image-version"

# Function to update ECS task definition for a microservice
function update_task_definition {
  local service_name=$1
  local task_definition_name="your-task-definition-name-${service_name}"

  # Update the ECS task definition with the new image version
  TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition $task_definition_name)
  CONTAINER_DEFINITIONS=$(echo $TASK_DEFINITION | jq '.taskDefinition.containerDefinitions')
  UPDATED_CONTAINER_DEFINITIONS=$(echo $CONTAINER_DEFINITIONS | jq --arg IMAGE_VERSION $NEW_IMAGE_VERSION '.[0].image = "YOUR_ECR_REPO_URL_'${service_name}':" + $IMAGE_VERSION')
  UPDATED_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --argjson CONTAINER_DEFINITIONS "$UPDATED_CONTAINER_DEFINITIONS" '.taskDefinition.containerDefinitions = $CONTAINER_DEFINITIONS')

  # Register the updated task definition
  REGISTERED_TASK_DEFINITION=$(aws ecs register-task-definition --cli-input-json "$UPDATED_TASK_DEFINITION")

  # Update the service with the new task definition
  UPDATED_SERVICE=$(aws ecs update-service --cluster $CLUSTER_NAME --service $service_name --task-definition $REGISTERED_TASK_DEFINITION.taskDefinition.taskDefinitionArn)
}

# Call the function for each microservice
update_task_definition $COMMON_SERVICE
update_task_definition $CUSTOMER_SERVICE
update_task_definition $ORDER_SERVICE
update_task_definition $PRODUCT_SERVICE
update_task_definition $USER_SERVICE
