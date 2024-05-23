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
echo "Protocol 2" >> /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "AuthorizedKeysFile /kaggle/working/.ssh/authorized_keys" >> /etc/ssh/sshd_config
echo "TCPKeepAlive yes" >> /etc/ssh/sshd_config
echo "X11Forwarding yes" >> /etc/ssh/sshd_config
echo "X11DisplayOffset 10" >> /etc/ssh/sshd_config
echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config
echo "HostbasedAuthentication no" >> /etc/ssh/sshd_config
echo "PrintLastLog yes" >> /etc/ssh/sshd_config
echo "AcceptEnv LANG LC_*" >> /etc/ssh/sshd_config

# Update and install SSH server
apt-get update
apt-get install -y openssh-server
service ssh start
service ssh restart

