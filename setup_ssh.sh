#!/bin/bash

set -e  # Exit immediately if a command exits with

# Function to export environment variables from a file
export_env_vars_from_file() {
    local env_file=$1
    while IFS= read -r line; do
        if [[ "$line" =~ ^[A-Z0-9_]+=.* ]]; then
            export "$line"
        fi
    done < "$env_file"
}

# Path to the captured environment variables file
ENV_VARS_FILE=/kaggle/working/kaggle_env_vars.txt

# Ensure the environment variables file exists
if [ -f "$ENV_VARS_FILE" ]; then
    echo "Exporting environment variables from $ENV_VARS_FILE"
    export_env_vars_from_file "$ENV_VARS_FILE"
else
    echo "Environment variables file $ENV_VARS_FILE not found"
fi

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: ./setup_ssh.sh <authorized_keys_url>"
    exit 1
fi

# Get the authorized_keys URL from arguments
AUTH_KEYS_URL=$1

# Function to create .ssh directory and set permissions
setup_ssh_directory() {
    mkdir -p /kaggle/working/.ssh
    wget -qO- $AUTH_KEYS_URL > /kaggle/working/.ssh/authorized_keys
    chmod 700 /kaggle/working/.ssh
    chmod 600 /kaggle/working/.ssh/authorized_keys
}

# Function to create symlink
create_symlink() {
    ln -s /kaggle/working/Kaggle_VSCode_Remote_SSH/.vscode /kaggle/.vscode
    # Verify symlink
    ls -l /kaggle/.vscode
}

# Function to configure sshd
configure_sshd() {
    mkdir -p /var/run/sshd
    {
        echo "Port 22"
        echo "Protocol 2"
        echo "PermitRootLogin yes"
        echo "PasswordAuthentication yes"
        echo "PubkeyAuthentication yes"
        echo "AuthorizedKeysFile /kaggle/working/.ssh/authorized_keys"
        echo "TCPKeepAlive yes"
        echo "X11Forwarding yes"
        echo "X11DisplayOffset 10"
        echo "IgnoreRhosts yes"
        echo "HostbasedAuthentication no"
        echo "PrintLastLog yes"
        echo "ChallengeResponseAuthentication no"
        echo "UsePAM yes"
        echo "AcceptEnv LANG LC_*"
        echo "AllowTcpForwarding yes"
        echo "GatewayPorts yes"
        echo "PermitTunnel yes"
    } >> /etc/ssh/sshd_config
}

install_packages() {
    #echo "Ensuring MKL and CUDA are installed via conda..."
    #conda install -y mkl

    echo "Updating environment variables..."
    {
        echo 'export PATH=$PATH:/usr/local/cuda/bin:/usr/local/nvidia/bin:/opt/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
        echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/lib:/usr/local/lib/x86_64-linux-gnu:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/opt/conda/lib:$LD_LIBRARY_PATH'
        echo 'export CUDA_HOME=/usr/local/cuda'
    } >> /root/.bashrc

    # Source the bashrc immediately to apply changes for the current session
    source /root/.bashrc

    echo "Installing openssh-server..."
    apt-get update
    apt-get install -y openssh-server
}

# Function to start SSH service
start_ssh_service() {
    service ssh start
    service ssh restart
}

# Function to verify fastai import
verify_fastai_import() {
    echo "Verifying fastai import..."
    python3 -c "from fastai.vision.all import *;print('fastai import successful')"
}

# Remove the environment variables file
cleanup() {
    rm /kaggle/working/kaggle_env_vars.txt
}

# Run functions in parallel where possible
(
    setup_ssh_directory & 
    create_symlink &
    configure_sshd & 
    install_packages
    wait
    start_ssh_service &
    wait
    cleanup
)

echo "Setup script completed successfully"

