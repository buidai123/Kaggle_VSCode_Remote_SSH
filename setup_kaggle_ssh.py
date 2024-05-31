import sys
import random
import string
import subprocess
import time
import json
import os

if len(sys.argv) != 2:
    print("Usage: python setup_kaggle_ssh.py <ngrok_authtoken>")
    exit(1)

ngrok_auth_token = sys.argv[1]

def generate_random_password(length=16):
    characters = (string.ascii_letters + string.digits + "!@#$%^*()-_=+{}[]<>.,?")
    return ''.join(random.choices(characters, k=length))

password = generate_random_password()
print(f"Setting password for root user: {password}")
subprocess.run(f"echo 'root:{password}' | sudo chpasswd", shell=True, check=True)

subprocess.run("service ssh start", check=True, shell=True)
subprocess.run("service ssh restart", check=True, shell=True)

subprocess.run(f"ngrok authtoken {ngrok_auth_token}", check=True, shell=True)

ngrok_process = subprocess.Popen(["ngrok", "tcp", "22", "--region", "ap"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

time.sleep(10)

def get_ngrok_tunnel():
    try:
        output = subprocess.check_output(["curl", "-s", "http://localhost:4040/api/tunnels"]).decode()
        tunnels = json.loads(output)
        for tunnel in tunnels['tunnels']:
            if tunnel['proto'] == 'tcp':
                return tunnel['public_url']
    except Exception as e:
        print(f"Failed to fetch tunnels: {str(e)}")
        return None

ngrok_url = get_ngrok_tunnel()
if ngrok_url:
    hostname = ngrok_url.split('//')[1].split(':')[0]
    port = ngrok_url.split(':')[2]

    print(f"ngrok tunnel opened at: {ngrok_url}")
    print(f"To connect via SSH, use the following command:")
    print(f"ssh root@{hostname} -p {port}")
    print(f"Password: {password}")
    sys.stdout.flush()
else:
    print("Failed to start ngrok tunnel.")
    exit(1)

try:
    ngrok_process.wait()
except KeyboardInterrupt:
    print("Shutting down ngrok tunnel")
    ngrok_process.terminate()
    ngrok_process.wait()

