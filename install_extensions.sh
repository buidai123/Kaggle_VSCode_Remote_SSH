#!/bin/bash

# Function to dynamically find the `code` command
update_path_for_code_command() {
    CODE_COMMAND_PATH=$(find /root/.vscode-server/cli/servers -name code -type f 2>/dev/null | grep '/remote-cli/code$' | head -n 1)
    if [ -n "$CODE_COMMAND_PATH" ]; then
        CODE_DIR=$(dirname "$CODE_COMMAND_PATH")
        if [[ ":$PATH:" != *":$CODE_DIR:"* ]]; then
            export PATH="$PATH:$CODE_DIR"
            echo "Added $CODE_DIR to PATH."
        fi
    else
        echo "VSCode `code` command not found."
        exit 1
    fi
}

# Update PATH to include `code` command dynamically
update_path_for_code_command

# List of extensions to install
extensions=(
    "ms-python.python"
    "ms-toolsai.jupyter"
    "esbenp.prettier-vscode"
)

# Install each extension
for extension in "${extensions[@]}"
do
    code --install-extension $extension
done

echo "All extensions have been installed."

