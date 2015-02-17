#!/usr/bin/env bash
#
# This bootstraps Puppet on Ubuntu 12.04 LTS.
#
set -e
# Load up the release information

#. /etc/lsb-release.d/*

REPO_URL="http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm"

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

# disable firewalld, NetworkManager
systemctl stop firewalld
systemctl disable firewalld
yum install -y iptables-services
# Create this below file, otherwise starting iptables will fail
touch /etc/sysconfig/iptables
systemctl enable iptables && systemctl start iptables

#systemctl stop NetworkManager.service
#systemctl disable NetworkManager.service
#rm /etc/sysconfig/network-scripts/ifcfg-enp5s0f1
#systemctl start network.service
#systemctl enable network.service
#systemctl status network.service
#--

if which puppet > /dev/null 2>&1; then
	echo "Puppet is already installed."
	exit 0
fi

# Install wget if we have to (some older Ubuntu versions)
echo "Installing wget..."
yum install -y wget >/dev/null

# Install the PuppetLabs repo
echo "Configuring PuppetLabs repo..."
repo_path=$(mktemp)
wget --output-document="${repo_path}" "${REPO_URL}" 2>/dev/null
rpm -i "${repo_path}" >/dev/null

# Install Puppet
echo "Installing Puppet..."
	yum install -y puppet > /dev/null
echo "Puppet installed!"

# Install RubyGems for the provider
echo "Installing RubyGems..."
yum install -y ruby-devel rubygems gcc g++ make automake autoconf curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel sqlite-devel >/dev/null
gem install --no-ri --no-rdoc rubygems-update
gem update >/dev/null

# Installing Puppet Modules
puppet module install puppetlabs/vcsrepo
puppet module install puppetlabs/stdlib
