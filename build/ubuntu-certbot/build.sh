#!/bin/bash

VAR_HOSTNAME="localhost"
# Update hosts file and add hostname
#/bin/sed -i -e "s#.*127.0.0.1 localhost.*#127.0.0.1 localhost $VAR_HOSTNAME#g" /etc/hosts
# Update hostname file
echo $VAR_HOSTNAME > /etc/hostname
# Update hostname without restart
hostname $VAR_HOSTNAME

apt update -y
apt upgrade -y

apt install -y nginx letsencrypt
