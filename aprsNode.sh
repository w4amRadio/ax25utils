#!/bin/bash
#To be used with RPi-3 or higher

sudo apt-get install -y gpsd gpsd-clients

sudo apt-get install -y axtools

sudo apt-get install -y direwolf

#set up direwolf to be run as a service

apt-get install -y xastir

user=$(whoami)
sudo usermod -a -G xastir-ax25 $user
