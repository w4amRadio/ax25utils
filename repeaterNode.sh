#!/bin/bash

user=$(logname)

mkdir /home/$user/tmp

apt-get install -y curl
apt-get install -y git
apt-get install -y gcc
apt-get install -y g++
apt-get install -y make
apt-get install -y cmake
apt-get install -y libasound2-dev
apt-get install -y libudev-dev

mkdir DependencyProjects
cd /home/$user/DependencyProjects
git clone https://www.github.com/wb2osz/direwolf
cd direwolf
git checkout dev
mkdir build && cd build
cmake ..
make
sudo make install
make install-conf

echo "Executing direwolf debian post-installation script..." >> /home/$user/tmp/installation.log 2>&1
chmod +x /home/$user/DependencyProjects/direwolf/debian/direwolf.postinst
bash /home/$user/DependencyProjects/direwolf/debian/direwolf.postinst

echo "Adding direwolf to group audio..." >> /home/$user/tmp/installation.log 2>&1
addgroup direwolf audio
