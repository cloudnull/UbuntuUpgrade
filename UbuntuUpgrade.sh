#!/bin/bash
# - title        : Ubuntu Upgrader
# - description  : This script will Upgrade Ubuntu to 12.04
# - author       : Kevin Carter
# - License      : GPLv3
# - date         : 2012-04-26
# - version      : 1
# - usage        : bash UbutuUpgrade.sh
# - OS Supported : Ubuntu 11.10
#### ========================================================================== ####

# Compatibility Test

OSTEST=`lsb_release -d | grep 11.10`
if [ -z "${OSTEST}" ];then 
clear
echo 'I am sorry thugh your Version of Ubuntu is NOT Supported.'
echo 'This Upgrade script only runs on Ubuntu 11.10'
echo ''
echo 'Here is your current version of Ubuntu'
lsb_release -a
exit 1
fi

# Welcome Message
clear
echo 'Welcome to the Ubuntu 12.04 Upgrade Installer'
echo 'This Script will Upgrade your existing Version of Ubuntu to the Current LTS Version'
sleep 2
echo '' 
echo 'This installation script comes AS IS and without warranty.'
echo 'If something is broken from using it, then it will be up to YOU to fix it.'
echo 'While I have tested this script on multiple installations'
echo 'including several production systems' 
echo 'there is no guarantee that it will work in all instances.'
echo 'This Script Automates the process for upgrading to Ubuntu 12.04,'
echo 'but you have to follow Instructions.'
echo 'Nobody will be responsible for your failure to follow instructions'
echo 'or any other incompatibility in your System.'
sleep 2
echo ''
echo 'If you Agree to these terms Please Press [ Enter ] to proceed.'
echo 'If you do NOT Agree then you can chicken out and press [ CTRL-C ]'
read -p "Please Agree or Disagree : "

# Preparing the System for the upgrade
echo 'System Prep...'
cp /etc/apt/sources.list /etc/apt/sources.list.old
sed -i 's/oneiric/precise/g' /etc/apt/sources.list
sed -i 's/defaults\,errors=remount-ro\,noatime/defaults\,errors=remount-ro\,noatime,barrier=0/g' /etc/fstab
apt-get update > /dev/null

echo "During the next segment you will be installing Grub2, which will require you to choose your ROOT device."
echo "The ROOT Device will be the primary partition you boot from."  
echo "In the Rackspace Cloud this would be the \"xvda\" device."
echo "WARNING IF YOU CHOOSE THE WRONG DEVICE YOU WILL BREAK YOUR SYSTEM!"
read -p "Press Enter to continue."
apt-get install grub2

clear
# Upgrade the Kernel 
echo "YOU MUST !!!" 
echo "If asked you must keep the local version currently installed for Grub and the Menu.list"
read -p "Press [ Enter ] to Continue"
echo 'Upgrading the Kernel'

# Getting Old Kernel Type 
OLDKERNEL=`ls /boot/vmlinuz-*-virtual|awk -F '-' '{print $2,$3}'|sed 's/\ /-/g' | head -1`

# Installing Kernel and Network Monitoring
apt-get -y install linux-image-3.2.*-virtual vnstat iptraf

echo 'Setting up Kernel Based Network Monitoring'
# Setup for Network Monitoring 
## Public Interface
vnstat -u -i eth0
## Private Interface
vnstat -u -i eth1

# Getting New Kernel Type 
NEWKERNEL=`ls /boot/vmlinuz-*-virtual|awk -F '-' '{print $2,$3}'|sed 's/\ /-/g'|grep -v 3.0.*|tail -1`

# Modify the Boot List so that it uses the New Kernel 
cp /boot/grub/menu.lst /boot/grub/menu.lst.old
sed -i "s/${OLDKERNEL}/${NEWKERNEL}/g" /boot/grub/menu.lst

clear
# Performing the Distribution Upgrade
echo "AGAIN YOU MUST !!!" 
echo "If asked you must keep the local version currently installed for Grub and the Menu.list"
read -p "Press [ Enter ] to Continue"
echo 'Upgrading the Kernel'
aptitude update > /dev/null 
aptitude -y dist-upgrade

clear
echo "FYI We installed Network Monitoring with 'vnstat' and 'iptraf'" 
echo 'All Done, enjoy your New Ubuntu 12.04 Server'
reboot now
exit 0
