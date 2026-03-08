#!/bin/bash

SPACE_ID=$1
BEARER_TOKEN=$2

# Get space name from Octopus API using the space ID
SPACE_NAME=$(curl -s -H "Authorization: Bearer ${BEARER_TOKEN}" \
  "https://mattc.octopus.app/api/spaces/${SPACE_ID}" | \
  jq -r '.Name')

if [ -z "$SPACE_NAME" ] || [ "$SPACE_NAME" == "null" ]; then
  echo "Error: Could not find space with ID ${SPACE_ID}"
  exit 1
fi

echo "Found space: ${SPACE_NAME} (${SPACE_ID})"

OCTOPUS_TEMPK8S_GRPC_HOSTNAME=mattc.octopus.app:8443 \
OCTOPUS_TEMPK8S_HOSTNAME=mattc.octopus.app \
OCTOPUS_TEMPK8S_POLLING_HOSTNAME=polling.mattc.octopus.app \
OCTOPUS_TEMPK8S_SPACE="${SPACE_NAME}" \
OCTOPUS_TEMPK8S_SPACE_ID="${SPACE_ID}" \
OCTOPUS_TEMPK8S_BEARER_TOKEN="${BEARER_TOKEN}" \
vagrant up