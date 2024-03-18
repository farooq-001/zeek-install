#!/bin/bash

# Function to start the download
start_download() {
    # Your download logic here
    echo "Starting download..."
# Create the systemd service file
sudo tee << EOF /etc/systemd/system/json-convert.service
[Unit]
Description=Python script conversion service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /etc/python-convert.py
StartLimitInterval=10s
StartLimitBurst=5
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Create the Python script file
sudo tee << EOF /etc/python-convert.py
# Your Python script content here
print("Hello, this is the Python conversion script.")
EOF

# Enable and start the systemd service
sudo systemctl daemon-reload
sudo systemctl enable json-convert
sudo systemctl start json-convert











}

# Function to remove a file
remove_file() {
    # Your file removal logic here
    echo "Removing file..."
}

# Menu for selecting options
while true; do
    echo "Choose an option:"
    echo "1. Start download"
    echo "2. Remove file"
    echo "3. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1) start_download ;;
        2) remove_file ;;
        3) break ;;
        *) echo "Invalid choice. Please enter 1, 2, or 3." ;;
    esac
done
