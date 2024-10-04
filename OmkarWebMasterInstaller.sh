#!/bin/bash

# Script to install selected tools on Debian-based systems
# Tools: Apache2, MariaDB, PHP, Python3, Netcat, Nikto, Fluxion

# Function to check for root privileges
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root. Please run with sudo."
        exit 1
    fi
}

# Function to update the package list
update_system() {
    echo "Updating package list..."
    apt update && apt upgrade -y
}

# Function to install Apache2
install_apache2() {
    echo "Installing Apache2..."
    apt install apache2 -y
    systemctl enable apache2
    systemctl start apache2
    echo "Apache2 installed and started."
}

# Function to install MariaDB
install_mariadb() {
    echo "Installing MariaDB..."
    apt install mariadb-server mariadb-client -y
    systemctl enable mariadb
    systemctl start mariadb
    echo "MariaDB installed and started."
    mysql_secure_installation
}

# Function to install PHP
install_php() {
    echo "Installing PHP and required modules..."
    apt install php libapache2-mod-php php-mysql -y
    echo "PHP installed."
}

# Function to install Python3 and pip
install_python3() {
    echo "Installing Python3 and pip..."
    apt install python3 python3-pip -y
    echo "Python3 and pip installed."
}

# Function to install Netcat
install_netcat() {
    echo "Installing Netcat..."
    apt install netcat -y
    echo "Netcat installed."
}

# Function to install Nikto
install_nikto() {
    echo "Installing Nikto..."
    apt install nikto -y
    echo "Nikto installed."
}

# Function to install Fluxion
install_fluxion() {
    echo "Installing Fluxion..."
    apt install git -y
    git clone https://github.com/FluxionNetwork/fluxion.git
    cd fluxion || { echo "Failed to enter fluxion directory"; exit 1; }
    chmod +x fluxion.sh
    echo "Fluxion installed. You can run it by navigating to the fluxion directory and executing ./fluxion.sh"
    cd ..
}

# Function to display the menu
display_menu() {
    echo "Select tools to install:"
    echo "1) Apache2"
    echo "2) MariaDB"
    echo "3) PHP"
    echo "4) Python3"
    echo "5) Netcat"
    echo "6) Nikto"
    echo "7) Fluxion"
    echo "8) All"
    echo "9) Exit"
}

# Function to read user choice and install selected tools
install_tools() {
    while true; do
        display_menu
        read -p "Enter your choice (1-9): " choice

        case $choice in
            1) install_apache2 ;;
            2) install_mariadb ;;
            3) install_php ;;
            4) install_python3 ;;
            5) install_netcat ;;
            6) install_nikto ;;
            7) install_fluxion ;;
            8)
                install_apache2
                install_mariadb
                install_php
                install_python3
                install_netcat
                install_nikto
                install_fluxion
                break
                ;;
            9) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

# Main script execution
check_root
update_system
install_tools

echo "Selected tools installed successfully!"
