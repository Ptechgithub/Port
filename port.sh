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

# Read the new SSH port number entered by the user and validate it
read -p "Please enter a new SSH port: " new_port

# Check if the new port is a valid integer
if ! [[ "$new_port" =~ ^[0-9]+$ ]]; then
    echo "Invalid port number. Please enter a valid integer for the SSH port."
    exit 1
fi

# Check if the new port is different from the current ports and not used by another service
if [[ " ${current_ports[*]} " == *" $new_port "* ]] || sudo netstat -tuln | grep ":$new_port " >/dev/null; then
    echo "The new port is either the same as the current port(s) or already used by another service. Please enter a different SSH port."
    exit 1
fi

# Open the new SSH port in the firewall
sudo ufw allow ssh
echo "Port $new_port is now allowed in the firewall."

# Backup the original SSH configuration file
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Modify the port number in the SSH configuration file
sudo sed -i "s/^Port .*/Port $new_port/" /etc/ssh/sshd_config

# Restart the SSH service
sudo systemctl restart sshd.service

echo "The SSH port has been changed to $new_port. Please log in with the new port. If you cannot log in, please check whether the firewall allows $new_port."
