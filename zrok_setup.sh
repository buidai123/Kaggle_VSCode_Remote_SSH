#!/bin/bash

set -e

install_zrok() {
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

install_zrok
