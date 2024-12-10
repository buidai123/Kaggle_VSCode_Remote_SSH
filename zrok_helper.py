import sys
import time

from IPython.core.getipython import get_ipython

if len(sys.argv) < 2:
    print("Usage: python zrok_setup.py <zrok-token>")
    sys.exit(1)

ZROK_TOKEN = sys.argv[1]

def setup_zrok(token):
    ipython = get_ipython()

    if ipython is not None:
        try:
            # enable zrok
            print("enabling zrok...")
            ipython.system(f"zrok enable {token}")
            time.sleep(5) # wait for zrok to be ready

            # setup private share
            print("Setting up Zrok share...")
            ipython.system("zrok share private --backend-mode tcpTunnel localhost:22")
        except Exception as e:
            print(f"An error occurred: {e}")
            sys.exit(1)
    else:
        print("This script can only be run in an IPython environment.")
        sys.exit(1)

setup_zrok(ZROK_TOKEN)
