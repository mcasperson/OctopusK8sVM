#!/bin/bash

# Quickly create a temporary Kubernetes cluster in the "Scratchpad" space using Vagrant and Octopus REST API.

# Required variables
OCTOPUS_SERVER="mattc.octopus.app"
BEARER_TOKEN="$1"
SPACE_NAME="Scratchpad"

# Fetch the space ID using Octopus REST API
SPACE_ID=$(curl -s -H "Authorization: Bearer $BEARER_TOKEN" "https://$OCTOPUS_SERVER/api/spaces" | \
  jq -r ".Items[] | select(.Name==\"$SPACE_NAME\") | .Id")

if [ -z "$SPACE_ID" ]; then
  echo "Space '$SPACE_NAME' not found."
  exit 1
fi

OCTOPUS_TEMPK8S_GRPC_HOSTNAME=mattc.octopus.app:8443 \
OCTOPUS_TEMPK8S_HOSTNAME=mattc.octopus.app \
OCTOPUS_TEMPK8S_POLLING_HOSTNAME=polling.mattc.octopus.app \
OCTOPUS_TEMPK8S_SPACE=$SPACE_NAME \
OCTOPUS_TEMPK8S_SPACE_ID=$SPACE_ID \
BEARER_TOKEN=$BEARER_TOKEN \
vagrant up