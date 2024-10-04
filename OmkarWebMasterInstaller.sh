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

# Function to check if a tool is installed
is_installed() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Apache2
install_apache2() {
    if is_installed "apache2"; then
        echo "Apache2 is already installed."
    else
        echo "Installing Apache2..."
        apt install apache2 -y
        systemctl enable apache2
        systemctl start apache2
        echo "Apache2 installed and started."
    fi
}

# Function to install MariaDB
install_mariadb() {
    if is_installed "mysql"; then
        echo "MariaDB is already installed."
    else
        echo "Installing MariaDB..."
        apt install mariadb-server mariadb-client -y
        systemctl enable mariadb
        systemctl start mariadb
        echo "MariaDB installed and started."
        mysql_secure_installation

        # Create new user
        create_new_user
    fi
}

# Function to create a new MariaDB user
create_new_user() {
    read -p "Enter the new username for MariaDB: " new_user
    read -sp "Enter the password for the new user: " new_password
    echo

    # Create user and grant privileges
    mysql -u root -e "CREATE USER '$new_user'@'localhost' IDENTIFIED BY '$new_password';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$new_user'@'localhost';"
    mysql -u root -e "FLUSH PRIVILEGES;"

    echo "User '$new_user' created and granted privileges."
}

# Function to install PHP
install_php() {
    if is_installed "php"; then
        echo "PHP is already installed."
    else
        echo "Installing PHP and required modules..."
        apt install php libapache2-mod-php php-mysql -y
        echo "PHP installed."
    fi
}

# Function to install Python3 and pip
install_python3() {
    if is_installed "python3"; then
        echo "Python3 is already installed."
    else
        echo "Installing Python3 and pip..."
        apt install python3 python3-pip -y
        echo "Python3 and pip installed."
    fi
}

# Function to install Netcat
install_netcat() {
    if is_installed "nc"; then
        echo "Netcat is already installed."
    else
        echo "Installing Netcat..."
        apt install netcat -y
        echo "Netcat installed."
    fi
}

# Function to install Nikto
install_nikto() {
    if is_installed "nikto"; then
        echo "Nikto is already installed."
    else
        echo "Installing Nikto..."
        apt install nikto -y
        echo "Nikto installed."
    fi
}

# Function to install Fluxion
install_fluxion() {
    if [ -d "fluxion" ]; then
        echo "Fluxion is already installed."
    else
        echo "Installing Fluxion..."
        apt install git -y
        git clone https://github.com/FluxionNetwork/fluxion.git
        cd fluxion || { echo "Failed to enter fluxion directory"; exit 1; }
        chmod +x fluxion.sh
        echo "Fluxion installed. You can run it by navigating to the fluxion directory and executing ./fluxion.sh"
        cd ..
    fi
}

# Function to display the menu
display_menu() {
    echo "Select tools to install (separate multiple choices with spaces):"
    echo "1) Apache2"
    echo "2) MariaDB"
    echo "3) PHP"
    echo "4) Python3"
    echo "5) Netcat"
    echo "6) Nikto"
    echo "7) Fluxion"
    echo "8) Exit"
}

# Function to read user choice and install selected tools
install_tools() {
    while true; do
        display_menu
        read -p "Enter your choice (e.g., 1 3 5): " -a choices

        for choice in "${choices[@]}"; do
            case $choice in
                1) install_apache2 ;;
                2) install_mariadb ;;
                3) install_php ;;
                4) install_python3 ;;
                5) install_netcat ;;
                6) install_nikto ;;
                7) install_fluxion ;;
                8) echo "Exiting..."; exit 0 ;;
                *) echo "Invalid choice: $choice. Skipping." ;;
            esac
        done

        echo "All selected tools processed. Please select more tools or exit."
    done
}

# Main script execution
check_root
install_tools

echo "Selected tools installation process completed!"
