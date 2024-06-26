#!/bin/bash
# https://software.opensuse.org/download.html?project=security%3Azeek&package=zeek
# https://www.howtoforge.com/how-to-install-zeek-network-security-monitoring-tool-on-ubuntu-22-04/
# Function to display messages and get user input
get_input() {
    echo "SNB-Chat-bot: $1"
    read -r user_input
}

# Welcome message
echo "SNB-Chat-bot: Hi, what's your name?"
read -r name

# Greet the user by name
echo "SNB-Chat-bot: Hi $name!"

# Ask if the user wants to continue
get_input "Do you want to continue? (yes/no)"

# Check the user's response
if [[ "$user_input" =~ ^[Yy] ]]; then
    echo "SNB-Chat-bot: Great! You need to install zeek. Do you want to proceed? (yes/no)"

    # Check the user's response
    get_input "Do you want to install zeek? (yes/no)"
    
    # Check the user's response
    if [[ "$user_input" =~ ^[Yy] ]]; then
        # Execute the installation script
        echo "SNB-Chat-bot: Installing zeek..."

##############################################################################################################
echo  --------------"It will be start 30 Sec"------------
sleep 30
sudo apt update -y
sudo apt upgrade -y
sudo mkdir /var/log/capture
sudo mkdir /var/log/capture/zipped

echo "Enter server IP address:"
read server_ip

echo "Enter interface name:"
read interface

if grep -q 'Ubuntu 22.04' /etc/os-release; then
    echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/security:zeek.list
    curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null
    sudo apt update
    sudo apt install zeek -y
elif grep -q 'Ubuntu 20.04' /etc/os-release; then
    echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/security:zeek.list
    curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_20.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null
    sudo apt update
    sudo apt install zeek -y
fi

echo "export PATH=$PATH:/opt/zeek/bin" >> ~/.bashrc
cd 
source .bashrc
echo "Enter source .bashrc command:"
read cammand
sudo $cammand

zeek --version  
sleep 10

cat << EOF | sudo tee /opt/zeek/etc/networks.cfg
10.0.0.0/8          Private IP space
172.16.0.0/12       Private IP space
192.168.0.0/16      Private IP space
EOF

cat << EOF | sudo tee /opt/zeek/etc/node.cfg
[zeek-logger]
type=logger
host=$server_ip
#
[zeek-manager]
type=manager
host=$server_ip
#
[zeek-proxy]
type=proxy
host=$server_ip
#
[zeek-worker]
type=worker
host=$server_ip
interface=$interface
#
[zeek-worker-lo]
type=worker
host=localhost
interface=$interface
EOF

zeekctl check
zeekctl deploy
zeekctl status
ls -l /opt/zeek/logs/current/
sleep 10
tail /opt/zeek/logs/current/conn.log
sleep 10

echo zeekctl check
echo zeekctl deploy
echo zeekctl status
##############################################################################################################################################################################################################
        echo "SNB-Chat-bot: zeek installation completed!"
    else
        echo "SNB-Chat-bot: Okay, stopping the process. If you change your mind, feel free to restart the chatbot Mr/Mis $name!."
    fi
else
    echo "SNB-Chat-bot: Okay, stopping the process. If you change your mind, feel free to restart the chatbot Mr/Mis $name!."
fi
