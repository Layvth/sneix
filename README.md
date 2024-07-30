# Wnockx - Automated Aircrack-ng Tool for WPA Brute Force

## Description
Wnockx is a bash script designed to automate the process of cracking WPA/WPA2 Wi-Fi passwords using Aircrack-ng suite tools. It simplifies the workflow by scanning Wi-Fi networks, filtering essential information, initiating deauthentication attacks, capturing handshakes, and performing brute-force attacks using specified wordlists.

The script utilizes bash scripting and tools like Aircrack-ng, Airodump-ng, Aireplay-ng, and Xterm to automate these complex tasks, reducing manual errors and speeding up the process.
<p align="center"><img src="https://github.com/Layvth/wnockx/blob/main/src/banner.png" width="800" alt="Image description"></p>

## Features
- **Network Scanning:** Scans for Wi-Fi networks and displays essential information.
- **Automated Filtering:** Filters and saves relevant network information for targeted attacks.
- **Deauthentication Attacks:** Sends deauthentication packets to disconnect clients and capture handshakes.
- **Handshake Capture:** Captures WPA/WPA2 handshakes for offline password cracking.
- **Brute Force Attack:** Initiates brute force attacks using specified wordlists to crack captured handshakes.
## Prerequisites
- Linux OS
- Aircrack-ng suite (`aircrack-ng`, `airodump-ng`, `aireplay-ng`)
- Xterm (for graphical output during scans and attacks)


## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Layvth/wnockx

## Usage
1. Ensure your network interface supports monitor mode and required tools are installed.
2. Run the script with root permissions (`sudo su && ./wnockx.sh`) to initiate the tool.
3. Follow on-screen instructions to select target networks, capture handshakes, and start brute-force attacks.
