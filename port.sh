#!/bin/bash

# Get the current SSH ports from the SSH configuration file (including lines starting with #Port)
current_ports_with_comments=($(grep -Eo '^[[:space:]]*#Port[[:space:]]+[0-9]+' /etc/ssh/sshd_config | awk '{print $2}'))

# Remove # from the beginning of the ports
current_ports=()
for port in "${current_ports_with_comments[@]}"; do
    current_ports+=("${port/#/}")
done

# Display the current SSH ports
if [ "${#current_ports[@]}" -eq 1 ]; then
    echo "Your SSH port is: ${current_ports[0]}"
elif [ "${#current_ports[@]}" -gt 1 ]; then
    echo "Your SSH ports are: ${current_ports[@]}"
else
    echo "No valid SSH port found in the configuration file."
fi

# Read the new SSH port number entered by the user
read -p "Please enter a new SSH port: " new_port

# Check if the new port is different from the current ports
while [[ " ${current_ports[*]} " == *" $new_port "* ]]; do
    echo "The new port cannot be the same as the current port. Please enter a different SSH port."
    read -p "Please enter a new SSH port: " new_port
done

# Open the new SSH port in the firewall
sudo ufw allow $new_port
echo "Port $new_port is now allowed in the firewall."

# Backup the original SSH configuration file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Modify the port number in the SSH configuration file
for port in "${current_ports[@]}"; do
    sed -i "s/Port $port/Port $new_port/g" /etc/ssh/sshd_config
done

# Restart the SSH service
sudo systemctl restart sshd.service

echo "The SSH ports have been changed to $new_port. Please log in with the new port. If you cannot log in, please check whether the firewall allows $new_port."
