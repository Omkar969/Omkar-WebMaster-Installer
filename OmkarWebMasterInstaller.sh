#!/bin/bash

# Define log file
LOG_FILE="install_web_stack.log"
> "$LOG_FILE"

# Function to print and log messages with timestamp
log_message() {
    local TIMESTAMP
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "$TIMESTAMP: $1"
    echo -e "$TIMESTAMP: $1" >> "$LOG_FILE"
}

# Function to print section headers
print_message() {
    log_message "\n============================================================"
    log_message "$1"
    log_message "============================================================\n"
}

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -qw "$1"
}

# Function to install a package with error handling
install_package() {
    PACKAGE=$1
    if is_installed "$PACKAGE"; then
        log_message "$PACKAGE is already installed. Skipping."
    else
        print_message "Installing $PACKAGE..."
        if sudo apt install "$PACKAGE" -y >> "$LOG_FILE" 2>&1; then
            log_message "$PACKAGE installation completed."
        else
            log_message "Error installing $PACKAGE. Check the log for details."
        fi
    fi
}

# Function to install common dependencies
install_dependencies() {
    local DEPS=("apache2" "php" "libapache2-mod-php" "php-mysql" "python3" "mariadb-server" "nikto" "netcat")
    for DEP in "${DEPS[@]}"; do
        install_package "$DEP"
    done
}

# Function to prompt user for software selection
menu_selection() {
    echo -e "\033[1;36mSelect the software components you want to install (e.g., 1 3 5):\033[0m"
    echo -e "\033[1;32mWeb Servers:\033[0m"
    echo "1) Apache2 - Leading web server software for serving web content."
    echo -e "\033[1;32mScripting Languages:\033[0m"
    echo "2) PHP - Popular server-side scripting language for web development."
    echo "3) Python3 - Versatile programming language for various applications."
    echo -e "\033[1;32mDatabase:\033[0m"
    echo "4) MariaDB - Powerful open-source database management system."
    echo -e "\033[1;32mWeb Applications:\033[0m"
    echo "5) DVWA - Damn Vulnerable Web Application for learning about web vulnerabilities."
    echo -e "\033[1;32mSecurity Tools:\033[0m"
    echo "6) Fluxion - Security tool for auditing Wi-Fi networks."
    echo "7) Nikto - Web server scanner to detect vulnerabilities and configuration issues."
    echo "8) Netcat - Networking utility for reading and writing data across networks."
    echo -e "\033[1;36mOptions:\033[0m"
    echo "9) All - Install all the above tools."
    echo "10) None - Exit the installer."

    read -p "Enter your choice (e.g., 1 2 3 for multiple selections): " selection
    echo "$selection"
}

# Function to confirm choices
confirm_choices() {
    log_message "You have selected the following components to install: $1"
    read -p "Are you sure you want to proceed? (yes/no): " confirm
    if [[ "$confirm" != "yes" && "$confirm" != "y" ]]; then
        log_message "Installation aborted by user."
        exit 1
    fi
}

# Function to validate the user input
validate_selection() {
    local selection="$1"
    local valid_choices="1 2 3 4 5 6 7 8 9 10"
    for choice in $selection; do
        if [[ ! " $valid_choices " =~ " $choice " ]]; then
            echo -e "\033[1;31mInvalid selection: $choice. Please enter valid options.\033[0m"
            return 1
        fi
    done
    return 0
}

# Main script logic
print_message "Starting installation script..."

# Immediately show the menu after printing the header
choices=""
while true; do
    choices=$(menu_selection)
    
    # Validate user input
    if validate_selection "$choices"; then
        break
    fi
done

confirm_choices "$choices"

# Parse user choices and install selected components
for choice in $choices; do
    case "$choice" in
        1) install_package "apache2" ;;
        2) install_package "php libapache2-mod-php php-mysql" ;;
        3) install_package "python3" ;;
        4) install_mariadb ;;
        5) install_dvwa ;;
        6) install_fluxion ;;
        7) install_package "nikto" ;;
        8) install_package "netcat" ;;
        9) 
            install_dependencies
            install_mariadb
            install_dvwa
            install_fluxion
            ;;
        10) log_message "No components selected. Exiting." ;;
        *) log_message "Invalid selection: $choice. Skipping." ;;
    esac
done

print_message "Installation completed! Check the log file for more details: $LOG_FILE."
