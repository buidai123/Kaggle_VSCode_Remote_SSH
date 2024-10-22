#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status

# Function to export environment variables from a file
export_env_vars_from_file() {
    local env_file=$1
    while IFS= read -r line; do
        if [[ "$line" =~ ^[A-Z0-9_]+=.* ]]; then
            export "$line"
        fi
    done <"$env_file"
}

# Path to the captured environment variables file
ENV_VARS_FILE=/kaggle/working/kaggle_env_vars.txt

if [ -f "$ENV_VARS_FILE" ]; then
    echo "Exporting environment variables from $ENV_VARS_FILE"
    export_env_vars_from_file "$ENV_VARS_FILE"
else
    echo "Environment variables file $ENV_VARS_FILE not found"
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: ./setup_ssh.sh <authorized_keys_url>"
    exit 1
fi

AUTH_KEYS_URL=$1

setup_ssh_directory() {
    mkdir -p /kaggle/working/.ssh
    if wget -qO /kaggle/working/.ssh/authorized_keys "$AUTH_KEYS_URL"; then
        chmod 700 /kaggle/working/.ssh
        chmod 600 /kaggle/working/.ssh/authorized_keys
    else
        echo "Failed to download authorized keys from $AUTH_KEYS_URL, please make sure to copy the raw url as said in the docs."
        exit 1
    fi
}

create_symlink() {
    if [ -d /kaggle/working/Kaggle_VSCode_Remote_SSH/.vscode ]; then
        [ -L /kaggle/.vscode ] && rm /kaggle/.vscode
        ln -s /kaggle/working/Kaggle_VSCode_Remote_SSH/.vscode /kaggle/.vscode
        echo "Symlink to .vscode folder created."
        ls -l /kaggle/.vscode
    else
        echo ".vscode directory not found in repository."
    fi
}

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
        echo "ClientAliveInterval 60"
        echo "ClientAliveCountMax 2"
    } >>/etc/ssh/sshd_config
}

install_packages() {
    echo "Updating environment variables..."
    {
        echo 'export PATH=$PATH:/usr/local/cuda/bin:/usr/local/nvidia/bin:/opt/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
        echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/lib:/usr/local/lib/x86_64-linux-gnu:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/opt/conda/lib:$LD_LIBRARY_PATH'
        echo 'export CUDA_HOME=/usr/local/cuda'
    } >>/root/.bashrc
    source /root/.bashrc

    echo "Installing openssh-server..."
    sudo apt-get update
    sudo apt-get install -y openssh-server
}

start_ssh_service() {
    service ssh start
    service ssh enable
    service ssh restart
}

cleanup() {
    [ -f /kaggle/working/kaggle_env_vars.txt ] && rm /kaggle/working/kaggle_env_vars.txt
}

(
    install_packages
    setup_ssh_directory &
    create_symlink &
    configure_sshd &
    wait
    start_ssh_service &
    wait
    cleanup
)

echo "Setup script completed successfully"
echo "All tasks completed successfully"
