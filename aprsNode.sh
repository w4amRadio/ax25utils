#!/bin/bash
#parameters are callsign, assignment

#assignment is for aprs receiver station, operator, or digipeater

callsign=$1
assignment=$2

mkdir ~/tmp

echo "Installing curl..." > ~/tmp/installation.log 2>&1
apt-get install -y curl

echo "Installing git..." >> ~/tmp/installation.log 2>&1
apt-get install -y git

echo "Installing gcc..." >> ~/tmp/installation.log 2>&1
apt-get install -y gcc

echo "Installing g++..." >> ~/tmp/installation.log 2>&1
apt-get install -y g++

echo "Installing make..." >> ~/tmp/installation.log 2>&1
apt-get install -y make

echo "Installing cmake..." >> ~/tmp/installation.log 2>&1
apt-get install -y cmake

echo "Installing libasound2-dev..." >> ~/tmp/installation.log 2>&1
apt-get install -y libasound2-dev

echo "Installing libudev-dev..." >> ~/tmp/installation.log 2>&1
apt-get install -y libudev-dev

echo "Installing ser2net..." >> ~/tmp/installation.log 2>&1
apt-get install -y ser2net

echo "Installing gpsd and gpsd-clients..." >> ~/tmp/installation.log 2>&1
apt-get install -y gpsd gpsd-clients

echo "Installing libax25..." >> ~/tmp/installation.log 2>&1
apt-get install -y libax25

echo "Installing ax25-apps..." >> ~/tmp/installation.log 2>&1
apt-get install -y ax25-apps

echo "Installing ax25-tools..." >> ~/tmp/installation.log 2>&1
apt-get install -y ax25-tools

echo "Installing axtools..." >> ~/tmp/installation.log 2>&1
apt-get install -y axtools

echo "Configuring /etc/ax25/axports..." >> ~/tmp/installation.log 2>&1 
echo "ax0 ${callsign}-1 1200  255		7		2m packet radio" >> /etc/ax25/axports 

echo "Installing direwolf...." >> ~/tmp/installation.log 2>&1
git clone https://www.github.com/wb2osz/direwolf
mkdir ~/direwolf/build
cmake ~/direwolf
make ~/direwolf/build
make install ~/direwolf/build
make install-conf ~/direwolf/build

echo "Adding direwolf to group audio..." >> ~/tmp/installation.log 2>&1
addgroup direwolf audio

#at this point the signalink device should be plugged in
device = $(arecord -l | grep "CODEC [USB AUDIO  CODEC]")

#if a direwolf.conf is not already available then bring one down from our repo
searchResult=$(find / -name "direwolf.conf")

#set up direwolf to be run as a service, move direwolf.conf to expected location and alter config
sed -i 's/YOURCALLSIGN/$(callsign)/g' direwolf.conf

echo "[Unit]
Description=Direwolf TNC
Requires=
After=

[Service]
Type=simple
User=root
#TODO: parse searchResult
ExecStart=direwolf -t 0 -p -c direwolf.conf
LimitNOFILE=6000000

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/direwolf.service

systemctl daemon-reload
systemctl enable direwolf

echo "Starting direwolf...."
systemctl start direwolf

apt-get install -y xastir

#user should typically be pi
user=$(whoami)
usermod -a -G xastir-ax25 $user
