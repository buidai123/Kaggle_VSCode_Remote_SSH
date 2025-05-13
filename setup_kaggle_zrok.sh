#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status


if [ "$#" -ne 1 ]; then
    echo "Usage: ./setup_kaggle_zrok.sh <authorized_keys_url>"
    exit 1
fi

AUTH_KEYS_URL=$1

setup_ssh_directory() {
    echo "Setting up SSH directory in user's home..."
    # If running as root, $HOME/.ssh becomes /root/.ssh
    local ssh_dir_path="$HOME/.ssh" 
    mkdir -p "$ssh_dir_path"
    if wget -qO "$ssh_dir_path/authorized_keys" "$AUTH_KEYS_URL"; then
        chmod 700 "$ssh_dir_path"
        chmod 600 "$ssh_dir_path/authorized_keys"
        echo "SSH directory and authorized_keys set up in $ssh_dir_path"
    else
        echo "Failed to download authorized keys from $AUTH_KEYS_URL to $ssh_dir_path/authorized_keys."
        exit 1
    fi
}

create_symlink() {
    # The script is now expected to run from /tmp/Kaggle_VSCode_Remote_SSH
    local vscode_dir_in_repo="/tmp/Kaggle_VSCode_Remote_SSH/.vscode"
    if [ -d "$vscode_dir_in_repo" ]; then
        [ -L /kaggle/.vscode ] && rm -f /kaggle/.vscode # Use -f to suppress error if link doesn't exist
        ln -s "$vscode_dir_in_repo" /kaggle/.vscode
        echo "Symlink to .vscode folder created (points to $vscode_dir_in_repo)."
        ls -l /kaggle/.vscode
    else
        echo ".vscode directory not found in repository at $vscode_dir_in_repo."
    fi
}

configure_sshd() {
    mkdir -p /var/run/sshd
    echo "Configuring sshd..."
    # Appending settings to sshd_config. 
    # Consider a more robust method if the script might be run multiple times to avoid duplicates.
    cat << EOF >> /etc/ssh/sshd_config
Port 22
Protocol 2
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile %h/.ssh/authorized_keys
TCPKeepAlive yes
X11Forwarding yes
X11DisplayOffset 10
IgnoreRhosts yes
HostbasedAuthentication no
PrintLastLog yes
ChallengeResponseAuthentication no
UsePAM yes
AcceptEnv LANG LC_*
AllowTcpForwarding yes
GatewayPorts yes
PermitTunnel yes
ClientAliveInterval 60
ClientAliveCountMax 2
EOF
    # Add a newline to potentially separate future appends
    echo "" >> /etc/ssh/sshd_config
    echo "sshd_config updated. Note: Appended settings. Ensure no conflicting duplicates exist if run multiple times."
}

setup_environment_variables() {
    echo "Appending current environment variables to /root/.bashrc..."
    {
        echo "" # Add a newline for separation
        echo "# Added by setup_kaggle_zrok.sh: Kaggle instance environment variables"
        printenv | while IFS='=' read -r key value; do
          # Properly escape single quotes for bash export
          escaped_value_final=$(printf "%s" "$value" | sed "s/'/'\\''/g")
          if [[ "$key" != "PATH" && "$key" != "LD_LIBRARY_PATH" && "$key" != "CUDA_HOME" ]]; then
            echo "export ${key}='${escaped_value_final}'"
          fi
        done
        echo "# End of Kaggle instance environment variables"
        echo "" # Add a newline for separation
    } >>/root/.bashrc
    
    echo "Sourcing /root/.bashrc for current script session (best effort)..."
    source /root/.bashrc || echo "Warning: Sourcing /root/.bashrc encountered an issue. SSH sessions should still inherit env vars."
}

install_packages() {
    echo "Installing openssh-server..."
    sudo apt-get update
    sudo apt-get install -y openssh-server
}

install_zrok() {
  echo "Downloading latest zrok release"
  curl -s https://api.github.com/repos/openziti/zrok/releases/latest |
    grep "browser_download_url.*linux_amd64.tar.gz" |
    cut -d : -f 2,3 |
    tr -d \" |
    wget -qi -

  echo "Extracting Zrok"
  if ! tar -xzf zrok_*_linux_amd64.tar.gz -C /usr/local/bin/; then
    echo "ERROR: Failed to extract Zrok"
    exit 1
  fi
  rm zrok_*_linux_amd64.tar.gz

  # check if zrok is installed correctly
  if ! zrok version &>/dev/null; then
    echo "Error: Zrok install failed"
    exit 1
  fi

  echo "Zrok installed successfully:"
  zrok version
}

setup_install_extensions_command() {
    echo "Setting up 'install_extensions' command..."
    # SCRIPT_DIR will point to the directory where setup_kaggle_zrok.sh is located
    local SCRIPT_DIR
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    local install_script_source="$SCRIPT_DIR/install_extensions.sh" 
    local install_script_target="/usr/local/bin/install_extensions"

    if [ -f "$install_script_source" ]; then
        mkdir -p /usr/local/bin # Ensure target directory exists
        cp "$install_script_source" "$install_script_target"
        chmod +x "$install_script_target"
        echo "'install_extensions' command is now available from $install_script_target."
        echo "You can run 'install_extensions' in your terminal after SSHing."
    else
        echo "Warning: $install_script_source not found. 'install_extensions' command not set up."
    fi
}

start_ssh_service() {
    service ssh start
    service ssh enable
    service ssh restart
}

cleanup() {
    echo "Performing cleanup..."
    # No longer need to remove /kaggle/working/kaggle_env_vars.txt

    # Define the path to the repository that needs to be cleaned up (where this script runs from)
}

(
    # setup_environment_variables
    install_packages
    install_zrok
    setup_ssh_directory # Run sequentially
    configure_sshd      # Run sequentially
    create_symlink &
    setup_install_extensions_command 
    wait # For create_symlink
    start_ssh_service &
    wait # For start_ssh_service
    # Removed cleanup and chmod +x install_extensions.sh from this block
)

cleanup # Call cleanup after the main setup block

echo "Setup script completed. SSH service should be running."
# Removed the second "All tasks completed successfully" as it's redundant
