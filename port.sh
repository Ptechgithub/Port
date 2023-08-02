#!/bin/bash

# Get the current SSH ports from the SSH configuration file
current_ports=($(grep -Eo '^[^#]*Port[[:space:]]+[0-9]+' /etc/ssh/sshd_config | awk '{print $2}'))

# Check if there is more than one port
if [ "${#current_ports[@]}" -gt 1 ]; then
    # Display the current SSH ports separated by &
    joined_ports=$(IFS=' & '; echo "${current_ports[*]}")
    echo "Your current SSH ports are: $joined_ports"

    # Read the port number to change from the user
    read -p "Please enter the SSH port number you want to change: " selected_port

    # Check if the selected port is in the current ports list
    if [[ " ${current_ports[*]} " == *" $selected_port "* ]]; then
        # Read the new SSH port number from the user
        read -p "Please enter a new SSH port number: " new_port

        # Backup the original SSH configuration file
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

        # Modify the port number in the SSH configuration file
        sed -i "s/Port $selected_port/Port $new_port/g" /etc/ssh/sshd_config

        # Restart the SSH service
        systemctl restart sshd.service

        echo "The SSH port $selected_port has been changed to $new_port. Please log in with the new port. If you cannot log in, please check whether the firewall allows $new_port."
    else
        echo "Invalid port selection. The port $selected_port is not in the current SSH ports list."
    fi
else
    echo "There is only one SSH port ($current_ports). You can add more ports in the SSH configuration file before running this script to change a specific port."
fi
