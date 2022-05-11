#!/bin/bash
#To be used with RPi-3 or higher
#parameters are callsign, assignment

#assignment is for aprs receiver station, operator, or digipeater

callsign=$1
assignment=$2

apt-get install -y curl
apt-get install -y git
apt-get install -y gcc
apt-get install -y g++
apt-get install -y make
apt-get install -y cmake
apt-get install -y libasound2-dev
apt-get install -y libudev-dev

apt-get install -y ser2net

apt-get install -y gpsd gpsd-clients

apt-get install -y libax25
apt-get install -y ax25-apps
apt-get install -y ax25-tools
apt-get install -y axtools

echo "ax0 ${callsign}-1 1200  255		7		2m packet radio" >> /etc/ax25/axports 

apt-get install -y direwolf
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
