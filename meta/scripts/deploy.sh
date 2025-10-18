#!/usr/bin/env bash

set -euo pipefail

# Defaults
SSH_PORT=22

# Usage info
usage() {
  echo "Usage: $0 -h <flake-hostname> -s <ssh-hostname> [-p <ssh-port>]"
  exit 1
}

# Parse flags
while getopts ":h:s:p:" opt; do
  case ${opt} in
    h )
      FLAKE_HOSTNAME=$OPTARG
      ;;
    s )
      SSH_HOSTNAME=$OPTARG
      ;;
    p )
      SSH_PORT=$OPTARG
      ;;
    \? )
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    : )
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# Validate required args
if [[ -z "${FLAKE_HOSTNAME:-}" || -z "${SSH_HOSTNAME:-}" ]]; then
  usage
fi

# Construct flake
FLAKE=".#$FLAKE_HOSTNAME"

# Temp dir for extra files
EXTRA_FILES_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$EXTRA_FILES_DIR"
}
trap cleanup EXIT

# Create file structure and copy secret
mkdir -p "$EXTRA_FILES_DIR/etc/agenix"
cp secrets/keys/shared.agekey "$EXTRA_FILES_DIR/etc/agenix/"

# Run nixos-anywhere
nixos-anywhere --debug \
  --flake "$FLAKE" \
  --extra-files "$EXTRA_FILES_DIR" \
  --target-host "root@$SSH_HOSTNAME" \
  -p "$SSH_PORT"
