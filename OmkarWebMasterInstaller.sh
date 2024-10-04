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

# Function to prompt user for software selection
menu_selection() {
    echo -e "\033[1;36mSelect the software components you want to install:\033[0m"
    echo "1) Apache2 - Leading web server software for serving web content."
    echo "2) PHP - Popular server-side scripting language for web development."
    echo "3) Python3 - Versatile programming language for various applications."
    echo "4) MariaDB - Powerful open-source database management system."
    echo "5) DVWA - Damn Vulnerable Web Application for learning about web vulnerabilities."
    echo "6) Fluxion - Security tool for auditing Wi-Fi networks."
    echo "7) Nikto - Web server scanner to detect vulnerabilities and configuration issues."
    echo "8) Netcat - Networking utility for reading and writing data across networks."
    echo "9) All - Install all the above tools."
    echo "10) None - Exit the installer."
    
    read -p "Enter your choice (e.g., 1 2 3 for multiple selections): " selection
    echo "$selection"
}

# Function to install MariaDB with secure installation and create a user
install_mariadb() {
    if is_installed "mariadb-server"; then
        log_message "MariaDB is already installed. Skipping."
    else
        print_message "Installing MariaDB server..."
        sudo apt install mariadb-server -y >> "$LOG_FILE" 2>&1
        sudo systemctl enable mariadb
        sudo systemctl start mariadb

        print_message "Securing MariaDB installation (interactive)..."
        if sudo mysql_secure_installation; then
            log_message "MariaDB secured successfully."
        else
            log_message "Failed to secure MariaDB installation. Please check manually."
        fi
        
        # Creating a new user and granting privileges
        create_mariadb_user
    fi
}

# Function to create a new MariaDB user and grant privileges
create_mariadb_user() {
    read -p "Enter the new MariaDB username: " db_username
    read -sp "Enter the password for the new user: " db_password
    echo ""
    
    read -p "Enter the host for the new user (e.g., localhost): " db_host
    
    # Create the user and grant privileges
    print_message "Creating user '$db_username' and granting privileges..."

    # Automatically login to MariaDB and run the commands
    if sudo mysql -u root -p -e "CREATE USER '$db_username'@'$db_host' IDENTIFIED BY '$db_password'; GRANT ALL PRIVILEGES ON *.* TO '$db_username'@'$db_host' WITH GRANT OPTION; FLUSH PRIVILEGES;" >> "$LOG_FILE" 2>&1; then
        log_message "User '$db_username' created and granted all privileges."
    else
        log_message "Error creating user '$db_username'. Check the log for details."
    fi
}

# Function to install DVWA
install_dvwa() {
    print_message "Downloading and installing DVWA..."
    if wget https://raw.githubusercontent.com/IamCarron/DVWA-Script/main/Install-DVWA.sh -O Install-DVWA.sh >> "$LOG_FILE" 2>&1; then
        chmod +x Install-DVWA.sh
        if sudo ./Install-DVWA.sh >> "$LOG_FILE" 2>&1; then
            log_message "DVWA installation completed."
        else
            log_message "Error installing DVWA. Check the log for details."
        fi
    else
        log_message "Failed to download DVWA installation script."
    fi
}

# Function to install Fluxion
install_fluxion() {
    print_message "Installing Fluxion..."
    
    # Clone Fluxion repository
    if git clone https://www.github.com/FluxionNetwork/fluxion.git >> "$LOG_FILE" 2>&1; then
        cd fluxion || { log_message "Failed to enter Fluxion directory."; return; }

        # Install dependencies for Fluxion
        sudo apt install aircrack-ng isc-dhcp-server hostapd lighttpd bettercap mdk3 nmap -y >> "$LOG_FILE" 2>&1
        
        # Run installer script for Fluxion
        if sudo ./fluxion.sh >> "$LOG_FILE" 2>&1; then
            log_message "Fluxion installation completed."
        else
            log_message "Error during Fluxion installation. Check the log for details."
        fi
        
        cd ..  # Navigate back to the previous directory
    else
        log_message "Failed to clone Fluxion repository."
    fi
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

# Main script logic
print_message "Starting installation script..."

# Immediately show the menu after printing the header
choices=$(menu_selection)
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
            install_package "apache2"
            install_package "php libapache2-mod-php php-mysql"
            install_package "python3"
            install_mariadb
            install_dvwa
            install_fluxion
            install_package "nikto"
            install_package "netcat"
            ;;
        10) log_message "No components selected. Exiting." ;;
        *) log_message "Invalid selection: $choice. Skipping." ;;
    esac
done

print_message "Installation completed! Check the log file for more details: $LOG_FILE."
