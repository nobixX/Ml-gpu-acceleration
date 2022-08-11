#!/bin/bash

# do not continue script on errors
set -euo pipefail

#Install docker and nvidia-runtime
export DEBIAN_FRONTEND=noninteractive
apt update && apt install curl -y

#Adding package repository and the GPG key for nvidia conatiner runtime 
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

#Update cache and install nvidia conatiner runtime
apt-get update && apt install -y nvidia-docker2;
apt-get update && apt-get install -y nvidia-container-toolkit
systemctl restart docker
service docker restart

#Configuration for running  nvidia-driver container

sed -i 's/^#root/root/' /etc/nvidia-container-runtime/config.toml
tee /etc/modules-load.d/ipmi.conf <<< "ipmi_msghandler" \
  && tee /etc/modprobe.d/blacklist-nouveau.conf <<< "blacklist nouveau" \
  && tee -a /etc/modprobe.d/blacklist-nouveau.conf <<< "options nouveau modeset=0"
update-initramfs -u
apt-get dist-upgrade -y
sudo reboot































