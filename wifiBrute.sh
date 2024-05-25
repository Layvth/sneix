#!/bin/bash
# 
#
# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color



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
Layvth@Github
"
}
#////////////////////////////// airodump-ng running for get access AP //////////////
run_airodump() {
    local interface=$1
    echo -e "${GREEN}[+]~: ${NC}Scanning for Wi-Fi networks on interface $interface..."
    echo -e "${YELLOW}[+]~: When you Finish Scaning Press [Ctrl + c]"
    xterm -geometry 100x50 -e "airodump-ng $interface"
}






sendDeauth () {
  local bssid=$1
  local interface=$2
  aireplay-ng --deauth 50 -a $bassid $interface
}


check_monitor_mode_support() {
    # Check if the phy80211 directory exists for the interface
    if [ -d "/sys/class/net/$interface/phy80211" ]; then
        echo -e "${GREEN}[*]~: ${NC}Interface ($interface) supports monitor mode !"
        mode=$(iwconfig $interface | grep "Mode:" | awk '{print $4}')
        if [ "$mode" = "Mode:Monitor" ]; then
            echo -e "${GREEN}[+]~:${NC} You on ready in Monitro Mode !"
            checkTools
        else
            read -p "      Switch ($interface) to monitor mode (yes/no) : " response
            if [ "$response" == "yes" ] || [ "$response" == "y" ]; then
                sleep .7
                airmon-ng start $interface >> /dev/null
                sleep .5
                echo -e "${GREEN}[*]~:${NC}$infterface Switched to monitor mode !"
                sleep 1
                checkTools
            fi
        fi
        
    else
        echo -e "${RED}[!]~:${NC} Interface ($interface) does not support monitor mode"
        sleep .7
        echo -e "${RED}[!]~:${NC} Error : check your interface !${NC}"
        
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
checkRoot () { 
    if [ "$(id -u)" != "0" ]; then
        echo "[!] We need root permition !"
        echo "[+] Try run with [ sudo ./wifiBrute.sh] "
    else 
        clear
        banner
        check_monitor_mode_support
    fi
} 
checkTools () {
    echo -e "${GREEN}[+]~:${NC} Tools checking :"
    air=$(which aircrack-ng)
    if ! [ "$?" -eq "0" ]; then
      echo -e "     Aircrack-ng     ${RED}[Not Found] ${NC}"
      echo "[!] try [ apt-get install aircrack-ng ] " 
      exit 1
    else 
      echo -e "      Aircrack-ng            :${GREEN}[Found]${NC}"
      run_airodump $interface
    fi
}
checkRoot