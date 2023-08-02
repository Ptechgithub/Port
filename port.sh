#!/bin/bash

# Get the current SSH port from the SSH configuration file
current_port=$(grep -Eo '^[^#]*Port[[:space:]]+[0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

echo "Your SSH port is: $current_port"

# Read the new SSH port number entered by the user
read -p "Please enter a new SSH port number: " new_port

# Open the new SSH port in the firewall
sudo ufw allow $new_port
echo "Port $new_port is now allowed in the firewall."

# Backup the original SSH configuration file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Modify the port number in the SSH configuration file
sed -i "s/Port $current_port/Port $new_port/g" /etc/ssh/sshd_config

# Restart the SSH service
sudo systemctl restart sshd.service

echo "The SSH port has been changed from $current_port to $new_port. Please log in with the new port. If you cannot log in, please check whether the firewall allows $new_port."
