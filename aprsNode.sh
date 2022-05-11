#!/bin/bash
#To be used with RPi-3 or higher
#parameters are callsign, assignment

#assignment is for aprs receiver station, operator, or digipeater

callsign=$1
assignment=$2

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

#set up direwolf to be run as a service, move direwolf.conf to expected location and alter config
sed -i "s/YOURCALLSIGN/${callsign}/g" direwolf.conf

apt-get install -y xastir

#user should typically be pi
user=$(whoami)
usermod -a -G xastir-ax25 $user
