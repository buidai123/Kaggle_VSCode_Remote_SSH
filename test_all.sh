#!/bin/bash
set -e

echo "Starting automated test..."

echo "AUTH_KEYS_URL: $AUTH_KEYS_URL"
echo "ZROK_TOKEN: $ZROK_TOKEN"

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

echo "Running setup_kaggle_zrok.sh with URL: $AUTH_KEYS_URL"
./setup_kaggle_zrok.sh "$AUTH_KEYS_URL"

echo "Attempting to enable zrok with token..."
ZROK_CMD=""
if command -v zrok &> /dev/null; then
    ZROK_CMD="zrok"
elif [ -f "/usr/local/bin/zrok" ]; then
    ZROK_CMD="/usr/local/bin/zrok"
else
    echo "zrok executable not found after setup_kaggle_zrok.sh."
    exit 1
fi

echo "Using zrok command: $ZROK_CMD"
"$ZROK_CMD" enable "$ZROK_TOKEN"

# Optionally, test zrok share (headless, non-interactive)
echo "Testing zrok share private (headless)..."
"$ZROK_CMD" share private --backend-mode tcpTunnel localhost:22 &
sleep 5

# Check SSH service status
echo "Checking SSH service status..."
if service ssh status; then
  echo "SSH service is running."
else
  echo "SSH service does not appear to be running. Check setup_kaggle_zrok.sh logs."
fi

# disable zrok
"$ZROK_CMD" disable

echo "Automated test script completed."
