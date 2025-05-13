#!/bin/bash
set -e

echo "Starting automated test..."

if [ -z "$AUTH_KEYS_URL" ]; then
  echo "Error: AUTH_KEYS_URL environment variable is not set."
  echo "Provide it during 'docker build' using --build-arg AUTH_KEYS_URL_ARG=your_url"
  exit 1
fi

if [ -z "$ZROK_TOKEN" ]; then
  echo "Error: ZROK_TOKEN environment variable is not set."
  echo "Provide it during 'docker build' using --build-arg ZROK_TOKEN_ARG=your_token"
  exit 1
fi

echo "Running setup_ssh.sh with URL: $AUTH_KEYS_URL"
./setup_ssh.sh "$AUTH_KEYS_URL"

echo "Running zrok_setup.sh..."
./zrok_setup.sh

echo "Attempting to enable zrok with token..."
ZROK_CMD=""
if command -v zrok &> /dev/null; then
    ZROK_CMD="zrok"
elif [ -f "/usr/local/bin/zrok" ]; then
    ZROK_CMD="/usr/local/bin/zrok"
else
    echo "zrok executable not found after zrok_setup.sh."
    exit 1
fi

echo "Using zrok command: $ZROK_CMD"
"$ZROK_CMD" enable "$ZROK_TOKEN"

echo "Checking SSH service status..."
if service ssh status; then
  echo "SSH service is running."
else
  echo "SSH service does not appear to be running. Check setup_ssh.sh logs."
fi

echo "Automated test script completed."