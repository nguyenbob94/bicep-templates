#!/bin/bash
# Canonical is trash. That is all
sed -i 's/azure.archive.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
sed -i 's/security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

# Update apt cache
apt update

# Install packages
apt install nmap openvpn p7zip-full -y

# Clone repo to home directory. Home directory name defined by $0 param
git -C /home/$1/ clone --depth 1 https://github.com/danielmiessler/SecLists
wget https://github.com/OJ/gobuster/releases/download/v3.1.0/gobuster-linux-amd64.7z -P /home/$1/

7z e /home/$1/gobuster-linux-amd64.7z
#rm /home/$1/gobuster-linux-amd64.7z

# Scripts run by RunShellScrupt are executed as root. Change owner to vmUsername
chown -R $1:$1 /home/$1/gobuster-linux-amd64.7z.1
chown -R $1:$1 /home/$1/SecLists