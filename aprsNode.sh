#!/bin/bash
#To be used with RPi-3 or higher

apt-get install -y ser2net

apt-get install -y gpsd gpsd-clients

apt-get install -y axtools

apt-get install -y direwolf
addgroup direwolf audio

#set up direwolf to be run as a service, move direwolf.conf to expected location and alter config

apt-get install -y xastir

#user should typically be pi
user=$(whoami)
usermod -a -G xastir-ax25 $user
