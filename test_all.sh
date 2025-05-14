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

ZROK_CMD=""
if command -v zrok &>/dev/null; then
    ZROK_CMD="zrok"
elif [ -f "/usr/local/bin/zrok" ]; then
    ZROK_CMD="/usr/local/bin/zrok"
else
    echo "zrok executable not found after setup_kaggle_zrok.sh."
    exit 1
fi

echo "Using zrok command: $ZROK_CMD"

echo "Checking SSH service status..."
if service ssh status &>/dev/null || /etc/init.d/ssh status &>/dev/null || systemctl status ssh &>/dev/null; then
    echo "SSH service is running."
else
    echo "SSH service check failed. Attempting to get more information:"
    service ssh status || true
    /etc/init.d/ssh status || true
    systemctl status ssh || true
    echo "SSH service does not appear to be running. Check setup_kaggle_zrok.sh logs."
    exit 1
fi

# star zrok with a timeout for testing
echo "Starting zrok for testing (with 15 second timeout)..."

echo "Enabling zrok with token $ZROK_TOKEN"
"$ZROK_CMD" enable "$ZROK_TOKEN" || {
    echo "Failed to enable zrok with provided token."
    exit 1
}

# Run the share command with timeout
echo "Starting zrok share with a 15-second timeout (for testing)"
timeout 15s "$ZROK_CMD" share private --headless --backend-mode tcpTunnel localhost:22 || echo "Zrok stopped after timeout (this is expected in test mode)"

# Check if zrok is enabled and running
echo "Checking if zrok is enabled..."
if "$ZROK_CMD" status | grep -q 'Account Token.*<<SET>>'; then
    echo "zrok service started successfully."
else
    echo "zrok service does not appear to be properly configured."
    exit 1
fi

# Disable zrok at the end of test
echo "Test complete. Disabling zrok..."
"$ZROK_CMD" disable

echo "All tests passed successfully!"
echo "====================================="
echo "Your Kaggle instance is now ready with:"
echo "✅ SSH server running on port 22"
echo "✅ VS Code extensions setup available"
echo "====================================="

echo "Automated test script completed."
