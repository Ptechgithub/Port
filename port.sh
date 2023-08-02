#!/bin/bash

# Read the new SSH port number entered by the user
read -p "Please enter a new SSH port number: " new_port

# Get the current SSH port from the SSH configuration file
current_port=$(grep -Eo '^[^#]*Port[[:space:]]+[0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

# Backup the original SSH configuration file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Modify the port number in the SSH configuration file
sed -i "s/Port $current_port/Port $new_port/g" /etc/ssh/sshd_config

# Restart the SSH service
systemctl restart sshd.service

echo "The original port $current_port is invalid. The SSH port has been changed to $new_port. Please log in with the new port. If you cannot log in, please check whether the firewall allows $new_port."
