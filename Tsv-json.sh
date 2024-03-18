#!/bin/bash

# Function to start the download
start_download() {
    # Your download logic here
    echo "Starting download..."
    sudo apt update && sudo apt install python3 python3-pip -y && pip3 install python-dateutil
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
import json
import os
import time
import zipfile
from datetime import datetime, timedelta

# Input source directories
input_sources = ["/opt/zeek/logs/current/"]

# Output directories corresponding to input sources
output_directories = ["/var/log/capture/"]

def zip_files(directory):
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    zip_file_path = f"/var/log/capture/zipped/{timestamp}.zip"
    with zipfile.ZipFile(zip_file_path, 'w') as zipf:
        for root, _, files in os.walk(directory):
            for file in files:
                if file.endswith('.log'):
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, directory)
                    zipf.write(file_path, arcname=arcname)

def delete_files(directory, extension):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(extension):
                file_path = os.path.join(root, file)
                os.remove(file_path)

while True:
    for input_source, output_directory in zip(input_sources, output_directories):
        for file_name in os.listdir(input_source):
            if file_name.endswith(".log"):
                input_file_path = os.path.join(input_source, file_name)
                output_file_path = os.path.join(output_directory, file_name.replace(".log", ".log"))

                # Read the log file
                with open(input_file_path, "r") as file:
                    log_lines = file.readlines()

                # Process the log lines
                fields = []
                data = []

                for line in log_lines:
                    if line.startswith("#fields"):
                        fields = line.strip().split('\t')[1:]
                    elif not line.startswith("#") and line.strip():
                        values = line.strip().split('\t')
                        entry = {}
                        for field, value in zip(fields, values):
                            entry[field] = value
                        data.append(entry)

                # Convert each entry to a JSON string and write it to the output file
                with open(output_file_path, "w") as file:
                    for entry in data:
                        json_entry = json.dumps(entry)
                        file.write(json_entry + "\n")

                print(f"Converted {file_name} to JSON in linear format and saved in {output_file_path}")

    zip_files("/var/log/capture/")
    print("All output .log files zipped and saved in /var/log/capture/zipped/")
    
    # Sleep for 6 hours before running the loop again
    time.sleep(6 * 60 * 60)

    # Delete output .log files every 24 hours
    if datetime.now().hour % 24 == 0:
        delete_files("/var/log/capture/", ".log")
        print("Deleted all output .log files")

    # Delete zip files every 72 hours
    if datetime.now().hour % 72 == 0:
        delete_files("/var/log/capture/zipped/", ".zip")
        print("Deleted all zip files")

    # Sleep for 1 hour before checking again
    time.sleep(60 * 60)

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
    # Stop and disable the systemd service
sudo systemctl stop json-convert
sudo systemctl disable json-convert
sudo rm /etc/systemd/system/json-convert.service
sudo rm /etc/python-convert.py
sudo systemctl daemon-reload
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
