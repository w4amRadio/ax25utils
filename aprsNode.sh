#!/bin/bash
#parameters are callsign, assignment

#assignment is for aprs receiver station, operator, or digipeater

callsign=$1
assignment=$2

user=$(logname)

mkdir /home/$user/tmp

echo "Installing curl..." > /home/$user/tmp/installation.log 2>&1
apt-get install -y curl

echo "Installing git..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y git

echo "Installing gcc..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y gcc

echo "Installing g++..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y g++

echo "Installing make..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y make

echo "Installing cmake..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y cmake

echo "Installing libasound2-dev..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y libasound2-dev

echo "Installing libudev-dev..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y libudev-dev

echo "Installing ser2net..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y ser2net

echo "Installing gpsd and gpsd-clients..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y gpsd gpsd-clients

echo "Installing libgps-dev..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y libgps-dev

echo "Installing libax25..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y libax25

echo "Installing ax25-apps..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y ax25-apps

echo "Installing ax25-tools..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y ax25-tools

echo "Configuring /etc/ax25/axports..." >> /home/$user/tmp/installation.log 2>&1 
echo "ax0 ${callsign}-1 1200  255		7		2m packet radio" >> /etc/ax25/axports 

echo "Installing direwolf...." >> /home/$user/tmp/installation.log 2>&1
git clone https://www.github.com/wb2osz/direwolf
mkdir /home/$user/direwolf/build
cmake /home/$user/direwolf
make /home/$user/direwolf/build
make install /home/$user/direwolf/build
make install-conf /home/$user/direwolf/build

#pretty sure we should have a direwolf user to add to the audio group
direwolfUser=$(less passwd | grep direwolf)

echo "Adding direwolf to group audio..." >> /home/$user/tmp/installation.log 2>&1
addgroup direwolf audio

#at this point the signalink device should be plugged in
device = $(arecord -l | grep "CODEC [USB AUDIO  CODEC]")

#if a direwolf.conf is not already available then bring one down from our repo
searchResult=$(find / -name "direwolf.conf")

#set up direwolf to be run as a service, move direwolf.conf to expected location and alter config
echo "Configuring direwolf.conf..." >> /home/$user/tmp/installation.log 2>&1
sed -i 's/YOURCALLSIGN/$(callsign)/g' direwolf.conf

echo "Configuring direwolf service definition (/etc/systemd/system/direwolf.service) ..." >> /home/$user/tmp/installation.log 2>&1
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

echo "Reloading Daemons..." >> /home/$user/tmp/installation.log 2>&1
systemctl daemon-reload

echo "Enabling direwolf as a service..." >> /home/$user/tmp/installation.log 2>&1
systemctl enable direwolf

echo "Starting direwolf service..." >> /home/$user/tmp/installation.log 2>&1
systemctl start direwolf

echo "Installing Xastir..." >> /home/$user/tmp/installation.log 2>&1
apt-get install -y xastir

#user should typically be pi
usermod -a -G xastir-ax25 $user
