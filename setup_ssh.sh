#!/bin/bash

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

# Create .ssh directory and set appropriate permissions
mkdir -p /kaggle/working/.ssh
wget -qO- $AUTH_KEYS_URL > /kaggle/working/.ssh/authorized_keys
chmod 700 /kaggle/working/.ssh
chmod 600 /kaggle/working/.ssh/authorized_keys

# Create a symlink
ln -s /kaggle/working/Kaggle_VSCode_Remote_SSH/.vscode /kaggle/.vscode
# Verify symlink
ls -l /kaggle/.vscode

# Configure sshd server
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
} >> /etc/ssh/sshd_config

# Install MKL via conda
echo "Ensuring MKL is installed via conda..."
conda install -y mkl

# Add MKL libraries to LD_LIBRARY_PATH
echo "LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/opt/conda/lib" >> /root/.bashrc
echo "export LD_LIBRARY_PATH" >> /root/.bashrc

# Update LD_LIBRARY_PATH
source /root/.bashrc

# Debug LD_LIBRARY_PATH
echo "Final LD_LIBRARY_PATH after all setups:"
echo $LD_LIBRARY_PATH

# Update and install SSH server
apt-get update
apt-get install -y openssh-server
service ssh start
service ssh restart

# Verify if importing fastai.vision.all works
echo "Verifying fastai import..."
python3 -c "from fastai.vision.all import *;print('fastai import successful')"

echo "Setup script completed successfully"
