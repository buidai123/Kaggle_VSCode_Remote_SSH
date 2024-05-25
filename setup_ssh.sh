#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: ./setup_ssh.sh <authorized_keys_url>"
    exit 1
fi

# Refreshing environment variables capture early
printenv | grep -E '^[A-Z0-9_]+=.*' > /kaggle/working/raw_env_vars_pre_web.txt

echo "Capturing environment variables before any web operation..."
cat /kaggle/working/raw_env_vars_pre_web.txt

# Final filtering and cleaning steps for env_vars_pre_web.txt
grep -E '^[A-Z0-9_]+=.*' /kaggle/working/raw_env_vars_pre_web.txt > /kaggle/working/env_vars.txt
sed -i '/^CompetitionsDatasetsModelsCodeDiscussionsCourses/d' /kaggle/working/env_vars.txt
sed -i '/^search/d' /kaggle/working/env_vars.txt
sed -i '/^Skip to/d' /kaggle/working/env_vars.txt
sed -i '/^Here is the content of the URL\/Web Page:/d' /kaggle/working/env_vars.txt
sed -i '/^\s*$/d' /kaggle/working/env_vars.txt

echo "Final cleaned environment variables:"
cat /kaggle/working/env_vars.txt

# Load the cleaned environment variables
while IFS= read -r line; do
    if [[ "$line" =~ ^[A-Z0-9_]+=.* ]]; then
        echo "Exporting: $line"
        eval "export $line"
    fi
done < /kaggle/working/env_vars.txt

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

# Step 8: Debugging - Print the sourced LD_LIBRARY_PATH
echo "LD_LIBRARY_PATH in the script: $LD_LIBRARY_PATH"

