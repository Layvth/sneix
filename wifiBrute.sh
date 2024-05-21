#!/bin/bash
# 
#
#
#
#
os=$(uname)
homepath=$(echo ~)
user=$(who | cut -d ' ' -f1 | sort | uniq)
distro=$(awk {print $1} /etc/issue)
interface=$(ip link show | awk -F': ' '/^[0-9]+: [a-zA-Z0-9]+:/ {name=$2} END {print name}')

function banner () {
    echo "
     
       __ ___ __  ___ __ _______            __         
     |   Y   |__.'  _|__|   _   .----.--.--|  |_.-----.
     |.  |   |  |   _|  |.  1   |   _|  |  |   _|  -__|
     |. / \  |__|__| |__|.  _   |__| |_____|____|_____|
     |:      |          |:  1    \                     
     |::.|:. |          |::.. .  /                     
     |--- ---'          |--------
   "
}
check_monitor_mode_support() {
    # Check if the phy80211 directory exists for the interface
    if [ -d "/sys/class/net/$interface/phy80211" ]; then
        echo "     [*] Interface ($interface) supports monitor mode."
        read -p " [Enter for set $interface to monitor mode]"
        sleep .3
        if cat $interface | grep -q "Monitor"; then
            airmon-ng start $interface
            echo "   [*] $interface switched to monitor mode "
        else 
            echo "   [!] Error Please Run the script again ! "
                
    else
        echo "     [!] Interface ($interface) does not support monitor mode"
        sleep .5
        echo "     [!] Error : check your interface !"
        
        exit 1
    fi
}



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
banner    
check_monitor_mode_support













