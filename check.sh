#!/bin/bash

# Usage: ./wait_for_label.sh <namespace> <deployment_name> <label_key> <label_value> <timeout>
# Example: ./wait_for_label.sh default my-deployment my-label ready 300

NAMESPACE=$1
DEPLOYMENT_NAME=$2
LABEL_KEY=$3
LABEL_VALUE=$4
TIMEOUT=${5:-300}  # Default timeout is 300 seconds

if [[ -z "$NAMESPACE" || -z "$DEPLOYMENT_NAME" || -z "$LABEL_KEY" || -z "$LABEL_VALUE" ]]; then
  echo "Usage: $0 <namespace> <deployment_name> <label_key> <label_value> <timeout>"
  exit 1
fi

echo "Waiting for deployment '$DEPLOYMENT_NAME' in namespace '$NAMESPACE' to have label '$LABEL_KEY=$LABEL_VALUE' and be ready..."

end_time=$(( $(date +%s) + TIMEOUT ))

while true; do
  # Check if the label is set on the deployment
  current_label=$(kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o=jsonpath="{.metadata.labels['$LABEL_KEY']}")

  # Check if the deployment is ready
  ready_replicas=$(kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o=jsonpath="{.status.readyReplicas}")
  desired_replicas=$(kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o=jsonpath="{.spec.replicas}")

  # Check if the label matches and the deployment is ready
  if [[ "$current_label" == "$LABEL_VALUE" && "$ready_replicas" -eq "$desired_replicas" ]]; then
    echo "Deployment '$DEPLOYMENT_NAME' has the label '$LABEL_KEY=$LABEL_VALUE' and is ready."
    exit 0
  fi

  # Check if we've exceeded the timeout
  if [[ $(date +%s) -ge $end_time ]]; then
    echo "Timed out waiting for deployment '$DEPLOYMENT_NAME' to have label '$LABEL_KEY=$LABEL_VALUE' and be ready."
    exit 1
  fi

  # Wait a few seconds before checking again
  sleep 5
done
