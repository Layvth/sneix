#!/bin/bash
# 
#
#
#
#
os=$(uname)
homepath=$(echo ~)
user=$(who | cut -d ' ' -f1 | sort | uniq)
interface=$(ip link show | awk -F': ' '/^[0-9]+: [a-zA-Z0-9]+:/ {name=$2} END {print name}')

function banner () {
    echo "                            
       _ ___ _ _____         _       
 _ _ _|_|  _|_| __  |___ _ _| |_ ___ 
| | | | |  _| | __ -|  _| | |  _| -_|
|_____|_|_| |_|_____|_| |___|_| |___|                              
Layvth@Github/
"
}
check_monitor_mode_support() {
    # Check if the phy80211 directory exists for the interface
    if [ -d "/sys/class/net/$interface/phy80211" ]; then
        echo "[*]~: Interface ($interface) supports monitor mode !"
        read -p "[*]~: Set ($interface) to monitor mode (yes/no) : " response
        if [ "$response" == "yes" ] || [ "$response" == "y" ]; then
            sleep .7
            airmon-ng start $interface >> /dev/null
            echo "[*]~: $infterface switched to monitor mode !"
        else
            echo "Exit "
            exit 1
        fi 
    else
        echo "[!]~: Interface ($interface) does not support monitor mode"
        sleep .7
        echo "[!]~: Error : check your interface !"
        
        exit 1
    fi
}

ctrl_c () {
    echo "exiting"
    if iwconfig $interface | grep -q "Mode:Monitor"; then
        read -p "[*]~: Do you want to exit from Monitor mode (yes/no) : " check
        if [ "$check" == "yes" ] || [ "$check" == "y" ]; then
            echo $interface
            ifconfig $infterface down
            iwconfig $infterface mode managed
            ifconfig $infterface up
            echo "[*]~: Exiting from monitor Mode !"
            exit 1
        else
            echo "[*]~: Exit !"
            exit 1
        fi
    else
        echo "[*]~: Exit !"
        exit 1
    fi
}

trap ctrl_c SIGINT

# check for root permetion

if [ "$(id -u)" != "0" ]; then
    echo " we need root permition !"
    echo " try run with [ sudo ./wifiBrute.sh] "
fi
# check for aircrack-ng

air=$(which aircrack-ng)
if ! [ "$?" -eq "0" ]; then
    echo "aircrack-ng not found !"
    echo "try [ apt-get install aircrack-ng ] "
fi
clear
banner    
check_monitor_mode_support













