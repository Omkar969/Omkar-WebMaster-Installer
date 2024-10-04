#!/bin/bash

# Define log file
LOG_FILE="install_web_stack.log"
> $LOG_FILE

# Function to print and log messages
log_message() {
    echo -e "$1"
    echo -e "$1" >> "$LOG_FILE"
}

# Function to print section headers
print_message() {
    log_message "\n============================================================"
    log_message "$1"
    log_message "============================================================\n"
}

# Function to print the header
print_header() {
    echo -e "\n"
    echo -e "\033[1;34m============================================================\033[0m"
    echo -e "\033[1;32m             Welcome to the Web Stack Installer             \033[0m"
    echo -e "\033[1;33m                     Created by Omkar Gore                    \033[0m"
    echo -e "\033[1;34m============================================================\033[0m\n"
}

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -qw "$1"
}

# Function to prompt user for software selection
menu_selection() {
    echo -e "\033[1;36mSelect the software components you want to install:\033[0m"
    echo "1) Apache2"
    echo "2) PHP"
    echo "3) Python3"
    echo "4) MariaDB"
    echo "5) Fluxion"
    echo "6) Nikto"
    echo "7) Netcat"
    echo "8) All"
    echo "9) None (Exit)"
    
    read -p "Enter your choice (e.g., 1 2 3 for multiple selections): " selection
    echo "$selection"
}

# Function to install Apache2
install_apache2() {
    if is_installed "apache2"; then
        log_message "Apache2 is already installed. Skipping."
    else
        print_message "Installing Apache2..."
        sudo apt install apache2 -y >> "$LOG_FILE" 2>&1
        sudo systemctl enable apache2
        sudo systemctl start apache2
        log_message "Apache2 installation completed."
    fi
}

# Function to install PHP
install_php() {
    if is_installed "php"; then
        log_message "PHP is already installed. Skipping."
    else
        print_message "Installing PHP and required extensions..."
        sudo apt install php libapache2-mod-php php-mysql -y >> "$LOG_FILE" 2>&1
        log_message "PHP installation completed."
    fi
}

# Function to install Python3
install_python3() {
    if is_installed "python3"; then
        log_message "Python3 is already installed. Skipping."
    else
        print_message "Installing Python3..."
        sudo apt install python3 -y >> "$LOG_FILE" 2>&1
        log_message "Python3 installation completed."
    fi
}

# Function to install MariaDB
install_mariadb() {
    if is_installed "mariadb-server"; then
        log_message "MariaDB is already installed. Skipping."
    else
        print_message "Installing MariaDB server..."
        sudo apt install mariadb-server -y >> "$LOG_FILE" 2>&1
        sudo systemctl enable mariadb
        sudo systemctl start mariadb

        print_message "Securing MariaDB installation (interactive)..."
        sudo mysql_secure_installation
        log_message "MariaDB installation completed."
    fi
}

# Function to install DVWA
install_dvwa() {
    print_message "Downloading and installing DVWA..."
    wget https://raw.githubusercontent.com/IamCarron/DVWA-Script/main/Install-DVWA.sh >> "$LOG_FILE" 2>&1
    chmod +x Install-DVWA.sh
    sudo ./Install-DVWA.sh >> "$LOG_FILE" 2>&1
    log_message "DVWA installation completed."
}

# Function to install Fluxion
install_fluxion() {
    print_message "Installing Fluxion..."
    
    # Clone Fluxion repository
    git clone https://www.github.com/FluxionNetwork/fluxion.git >> "$LOG_FILE" 2>&1
    cd fluxion || exit

    # Install dependencies for Fluxion
    sudo apt install aircrack-ng isc-dhcp-server hostapd lighttpd bettercap mdk3 nmap -y >> "$LOG_FILE" 2>&1
    
    # Run installer script for Fluxion
    sudo ./fluxion.sh >> "$LOG_FILE" 2>&1
    
    cd ..  # Navigate back to the previous directory
    log_message "Fluxion installation completed."
}

# Function to install Nikto
install_nikto() {
    if is_installed "nikto"; then
        log_message "Nikto is already installed. Skipping."
    else
        print_message "Installing Nikto..."
        sudo apt install nikto -y >> "$LOG_FILE" 2>&1
        log_message "Nikto installation completed."
    fi
}

# Function to install Netcat
install_netcat() {
    if is_installed "netcat"; then
        log_message "Netcat is already installed. Skipping."
    else
        print_message "Installing Netcat..."
        sudo apt install netcat -y >> "$LOG_FILE" 2>&1
        log_message "Netcat installation completed."
    fi
}

# Function to confirm choices
confirm_choices() {
    log_message "You have selected the following components to install: $1"
    read -p "Are you sure you want to proceed? (yes/no): " confirm
    if [[ "$confirm" == "yes" || "$confirm" == "y" ]]; then
        return 0
    else
        log_message "Installation aborted by user."
        exit 1
    fi
}

# Main script logic
print_header

print_message "Starting installation script..."

# Update package list
print_message "Updating package list..."
sudo apt update -y >> "$LOG_FILE" 2>&1

# Get the user’s selection from the menu
choices=$(menu_selection)
confirm_choices "$choices"

# Parse user choices and install selected components
for choice in $choices; do
    case "$choice" in
        1) install_apache2 ;;
        2) install_php ;;
        3) install_python3 ;;
        4) install_mariadb ;;
        5) install_fluxion ;;
        6) install_nikto ;;
        7) install_netcat ;;
        8) install_apache2; install_php; install_python3; install_mariadb; install_fluxion; install_nikto; install_netcat ;;
        9) log_message "No components selected. Exiting." ;;
        *) log_message "Invalid selection: $choice. Skipping." ;;
    esac
done

# Install DVWA regardless of user choices (assumes it's required)
install_dvwa

print_message "Installation completed! Check the log file for more details: $LOG_FILE."
