import random
import string
import subprocess
import sys

from pyngrok import conf, ngrok

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

conf.get_default().auth_token = ngrok_auth_token
conf.get_default().region = 'ap'

# start ngrok tunnel
tunnel = ngrok.connect("22", "tcp")
ngrok_url = tunnel.public_url

if ngrok_url:
    hostname, port = ngrok_url.split("://")[1].split(":")
    print(f"ngrok tunnel opened at: {ngrok_url}")
    print("To connect via SSH, use the following command:")
    print(f"ssh root@{hostname} -p {port}")
    print(f"Password: {password}")
    sys.stdout.flush()
else:
    print("Failed to start ngrok tunnel.")
    exit(1)

ngrok_process = ngrok.get_ngrok_process()
try:
    # hit ctrl-c to stop ngrok, or just power off the noteboko
    ngrok_process.proc.wait()
except KeyboardInterrupt:
    print("Shutting down ngrok tunnel")
    ngrok.kill()
