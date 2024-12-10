#!/bin/bash

set -e

ZROK_TOKEN=$1

if [ -z "$ZROK_TOKEN" ]; then
  echo "Looks like you forgot to enter Zrok token?"
  echo "Usage: ./zrok_setup.sh <zrok-token>"
  exit 1
fi

install_Zrok() {
  echo "Downloading latest zrok release"
  curl -s https://api.github.com/repos/openziti/zrok/releases/latest |
    grep "browser_download_url.*linux_amd64.tar.gz" |
    cut -d : -f 2,3 |
    tr -d \" |
    wget -qi -

  echo "Extracting Zrok"
  if ! tar -xzf zrok_*_linux_amd64.tar.gz -C /usr/local/bin/; then
    echo "ERROR: Failed to extract Zrok"
    exit 1
  fi
  rm zrok_*_linux_amd64.tar.gz

  # check if zrok is installed correctly
  if ! zrok version &>/dev/null; then
    echo "Error: Zrok install failed"
    exit 1
  fi

  zrok version
}

setup_session() {
  echo "Setting up Zrok environment"
  # TODO: find a way to run zrok_helper in %%bash magic under ipython
  chmod +x ./zrok_helper.py # make sure the helper function executable

  python3 -c "
  import IPython
  IPython.start_ipython(argv=['--no-banner'])
  %run ./zrok_helper.py $ZROK_TOKEN
    "
}

install_Zrok
setup_session
