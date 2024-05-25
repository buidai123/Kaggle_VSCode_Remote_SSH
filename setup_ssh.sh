#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: ./setup_ssh.sh <authorized_keys_url>"
    exit 1
fi

# Get the authorized_keys URL from arguments
AUTH_KEYS_URL=$1

# Create a symlink
ln -s /kaggle/working/Kaggle_VSCode_Remote_SSH/.vscode /kaggle/.vscode
# Verify symlink
ls -l /kaggle/.vscode

# Create .ssh directory and set appropriate permissions
mkdir -p /kaggle/working/.ssh
wget -qO- $AUTH_KEYS_URL > /kaggle/working/.ssh/authorized_keys
chmod 700 /kaggle/working/.ssh
chmod 600 /kaggle/working/.ssh/authorized_keys

# Configure sshd server
mkdir -p /var/run/sshd
echo "Port 22" >> /etc/ssh/sshd_config
echo "Protocol 2" >> /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "AuthorizedKeysFile /kaggle/working/.ssh/authorized_keys" >> /etc/ssh/sshd_config

# Additional configurations to ensure smooth operation
echo "TCPKeepAlive yes" >> /etc/ssh/sshd_config
echo "X11Forwarding yes" >> /etc/ssh/sshd_config
echo "X11DisplayOffset 10" >> /etc/ssh/sshd_config
echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config
echo "HostbasedAuthentication no" >> /etc/ssh/sshd_config
echo "PrintLastLog yes" >> /etc/ssh/sshd_config
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
echo "UsePAM yes" >> /etc/ssh/sshd_config
echo "AcceptEnv LANG LC_*" >> /etc/ssh/sshd_config

# Set LD_LIBRARY_PATH for NVIDIA libraries
echo "LD_LIBRARY_PATH=/usr/lib64-nvidia" >> /root/.bashrc
echo "export LD_LIBRARY_PATH" >> /root/.bashrc

# Print LD_LIBRARY_PATH for debugging purposes
echo "LD_LIBRARY_PATH after setting in .bashrc:"
source /root/.bashrc
echo $LD_LIBRARY_PATH

# Update and install SSH server
apt-get update
apt-get install -y openssh-server
service ssh start
service ssh restart

# Capture the environment variables from notebook
printenv | grep -E '^[A-Z0-9_]+=.*' > /kaggle/working/env_vars.txt

# Remove web page content lines, if any
sed -i '/Skip to/d' /kaggle/working/env_vars.txt

# Ensure env_vars.txt does not have empty or malformed lines
sed -i '/^\s*$/d' /kaggle/working/env_vars.txt  # Remove empty lines

# Pause for 2 seconds to ensure the file operations are completed
sleep 2

# Source environment variables captured from Kaggle notebook
set -a
source /kaggle/working/env_vars.txt
set +a

# For debugging purposes, print the newly sourced environment variables
echo "LD_LIBRARY_PATH in the script: $LD_LIBRARY_PATH"

