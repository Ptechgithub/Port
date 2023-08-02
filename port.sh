#!/bin/bash

# Get the current SSH port number
current_port=$(grep -oP "(?<=Port )\S+" /etc/ssh/sshd_config)

# Display the current SSH port
echo "Current SSH port: $current_port"

# Read the new SSH port number entered by the user
read -p "Please enter a new SSH port (1_65535): " new_port

# Backup the original SSH configuration file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

sudo ufw allow $new_port

# Remove the # sign from the beginning of the Port line (if present)
sed -i "s/^#Port/Port/" /etc/ssh/sshd_config

# Set the new port number
sed -i "s/^Port .*/Port $new_port/" /etc/ssh/sshd_config

# Restart the SSH service
systemctl restart sshd.service

echo "The SSH port has been changed from $current_port to $new_port. Please log in with the new port. If you cannot log in, please check whether the firewall allows $new_port"
