#!/usr/bin/env bash
#
# This bootstraps Puppet on Ubuntu 12.04 LTS.
#
set -e
# Load up the release information

#. /etc/lsb-release.d/*

#--------------------------------------------------------------------
# NO TUNABLES BELOW THIS POINT
#--------------------------------------------------------------------
if [ "$EUID" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# disable Selinux
sed -i s/SELINUX=.*/SELINUX=disabled/ /etc/sysconfig/selinux
setenforce 0

systemctl stop NetworkManager.service
systemctl disable NetworkManager.service
rm /etc/sysconfig/network-scripts/ifcfg-enp5s0f1
systemctl start network.service
systemctl enable network.service
systemctl status network.service

