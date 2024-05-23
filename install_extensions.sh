#!/bin/bash

# List of extensions to install
extensions=(
    "ms-python.python"
    "ms-vscode-remote.remote-ssh"
    "ms-toolsai.jupyter"
    "esbenp.prettier-vscode"
)

# Install each extension
for extension in "${extensions[@]}"
do
    code --install-extension $extension
done

echo "All extensions have been installed."

