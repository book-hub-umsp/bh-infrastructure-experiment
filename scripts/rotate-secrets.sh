#!/usr/bin/env bash
set -euo pipefail

# Rotate Nomad variables for PAT tokens
# Requires:
# - Vault CLI configured
# - Nomad CLI with proper permissions
main() {
  local namespace="book-hub"
  local path="book-hub/secret/pat"
  
  echo "Rotating PAT tokens in Nomad variables..."
  
  nomad var put -namespace "$namespace" "$path" \
    GH_PAT="$(vault read -field=token secret/github)" \
    DOCKER_PAT="$(vault read -field=token secret/docker)"
  
  echo "Successfully rotated tokens at $(date +%Y-%m-%d_%H:%M:%S)"
}

main "$@"
