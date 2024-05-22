import sys
import random
import string
import subprocess
from pyngrok import ngrok
import time
import signal

# Validate the number of arguments passed
if len(sys.argv) != 2:
    print("Usage: python setup_kaggle_ssh.py <ngrok_authtoken>")
    exit(1)

# Get the ngrok auth token from arguments
ngrok_auth_token = sys.argv[1]

# Function to generate random password
def generate_random_password(length=16):
    characters = string.ascii_letters + string.digits + string.punctuation
    return ''.join(random.choices(characters, k=length))

# Generate random password and set it for root user
password = generate_random_password()
print(f"Setting password for root user: {password}")
subprocess.run(f"echo 'root:{password}' | sudo chpasswd", shell=True, check=True)

# Ensure SSH server is running and password authentication is enabled
subprocess.run("service ssh restart", shell=True, check=True)

# Set ngrok auth token
ngrok.set_auth_token(ngrok_auth_token)

# Start ngrok SSH tunnel
ssh_tunnel = ngrok.connect(22, "tcp")
ngrok_url = ssh_tunnel.public_url
hostname = ngrok_url.split('//')[1].split(':')[0]
port = ngrok_url.split(':')[2]

# Print SSH connection details
print(f"ngrok tunnel opened at: {ngrok_url}")
print(f"To connect via SSH, use the following command:")
print(f"ssh root@{hostname} -p {port}")
print(f"Password: {password}")

# Function to handle termination signals
def signal_handler(sig, frame):
    print("ngrok tunnel closed")
    ngrok.disconnect(ssh_tunnel)
    exit(0)

# Register signal handler for graceful termination
signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)

# Keep the script running
while True:
    time.sleep(10)

