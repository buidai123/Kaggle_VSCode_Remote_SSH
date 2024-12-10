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
  tar -xzf zrok_*_linux_amd64.tar.gz -C /usr/local/bin/
  rm zrok_*_linux_amd64.tar.gz

  zrok version
}

setup_session() {
  echo "Setting up Zrok environment"
  zrok enable "$ZROK_TOKEN"
  sleep 5
  zrok share private --backend-mode tcpTunnel localhost:22
}

install_Zrok
setup_session
