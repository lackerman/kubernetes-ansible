#!/bin/bash

##############################################################
# Ubuntu bootable-disk setup
#
# Sets up the system-boot partition of a bootable Ubuntu disk
# so that the current user's public key is already added as
# an authorized_key and ssh enabled on first boot.
##############################################################

usage() {
  echo "Usage: cmd [-h] [-u]
-p    The full path to Ubuntu system-boot partition
-h    This help message
"
}

while getopts "p:h" OPT; do
  case ${OPT} in
    p)  system_boot_path="${OPTARG}";;
    h)  usage ;;
    \?) usage ;;
  esac
done

if [ -z "$system_boot_path" ]; then
  printf "\nsystem-boot path is empty.\n\n"
  usage
  exit 1
fi

tee "$system_boot_path/user-data" <<EOF
#cloud-config

# On first boot, set the (default) ubuntu user's password to "ubuntu"
chpasswd:
  expire: false # don't expire the password since we're going to delete the user with ansible anyway
  list:
  - ubuntu:ubuntu

users:
  - default

# Disable password authentication with the SSH daemon
ssh_pwauth: false

ssh_authorized_keys:
  - $(cat "$HOME/.ssh/id_rsa.pub")
EOF

touch "$system_boot_path/ssh"
