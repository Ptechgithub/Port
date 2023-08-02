#!/bin/bash

# Read the new SSH port number entered by the user
read -p "Please enter a new SSH port number：" new_port

# Backup the original SSH configuration file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Modify the port number in the SSH configuration file
sed -i "s/#Port 22/Port $new_port/g" /etc/ssh/sshd_config

# Restart the SSH service
systemctl restart sshd.service

echo "The original port 22 is invalid. The SSH port has been changed to $new_port. Please log in with the new port. If you cannot log in, please check whether the firewall allows $new_port"
