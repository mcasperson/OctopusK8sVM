#!/usr/bin/env python3
import re
import sys

def extract_tokens(filename):
    """Extract bearer token and access token from helm command file."""
    try:
        with open(filename, 'r') as f:
            content = f.read()

        # Extract agent.bearerToken
        bearer_token_match = re.search(r'--set agent\.bearerToken="([^"]+)"', content)
        bearer_token = bearer_token_match.group(1) if bearer_token_match else ""

        # Extract kubernetesMonitor.registration.serverAccessToken
        access_token_match = re.search(r'--set kubernetesMonitor\.registration\.serverAccessToken="([^"]+)"', content)
        access_token = access_token_match.group(1) if access_token_match else ""

        # Extract agent.space
        space_match = re.search(r'--set agent\.space="([^"]+)"', content)
        space = space_match.group(1) if space_match else ""

        # Extract kubernetesMonitor.registration.spaceId
        space_id_match = re.search(r'--set kubernetesMonitor\.registration\.spaceId="([^"]+)"', content)
        space_id = space_id_match.group(1) if space_id_match else ""

        # Print the vagrant command with extracted values
        print(f"OCTOPUS_TEMPK8S_SPACE={space} OCTOPUS_TEMPK8S_SPACE_ID={space_id} OCTOPUS_TEMPK8S_BEARER_TOKEN={bearer_token} OCTOPUS_TEMPK8S_ACCESS_TOKEN={access_token} vagrant up")

    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    extract_tokens("helm.txt")

