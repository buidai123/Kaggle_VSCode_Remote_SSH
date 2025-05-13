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

echo "Running setup_kaggle_zrok.sh with URL: $AUTH_KEYS_URL and ZROK_TOKEN"
./setup_kaggle_zrok.sh "$AUTH_KEYS_URL" "$ZROK_TOKEN"

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

echo "Checking zrok status..."
if "$ZROK_CMD" list | grep -q "localhost:22"; then
    echo "zrok service is running correctly."
else
    echo "zrok service does not appear to be properly configured. Check setup_kaggle_zrok.sh logs."
    exit 1
fi

echo "All tests passed successfully!"
echo "====================================="
echo "Your Kaggle instance is now ready with:"
echo "✅ SSH server running on port 22"
echo "✅ zrok private tunnel enabled"
echo "✅ VS Code extensions setup available"
echo "====================================="

if [ "$CI" = "true" ] || [ "$TEST_MODE" = "true" ]; then
    echo "Test mode detected. Disabling zrok..."
    "$ZROK_CMD" disable
fi

echo "Automated test script completed."
