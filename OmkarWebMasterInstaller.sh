#!/bin/bash

# Script to install selected tools on Debian-based systems
# Tools: Apache2, MariaDB, PHP, Python3, Netcat, Nikto, Fluxion, Git, Curl, Nmap, OpenSSH Server, Wireshark, Docker, Metasploit, Burp Suite, Snort, Aircrack-ng, John the Ripper, OpenVAS, SQLMap, Ettercap

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

# Function to install a tool if it's not already installed
install_tool() {
    local tool_name="$1"
    local install_command="$2"

    if is_installed "$tool_name"; then
        echo "$tool_name is already installed."
    else
        echo "Installing $tool_name..."
        eval "$install_command"
        echo "$tool_name installed."
    fi
}

# Function to install tools
install_apache2() { install_tool "apache2" "apt install apache2 -y && systemctl enable apache2 && systemctl start apache2"; }
install_mariadb() { install_tool "mysql" "apt install mariadb-server mariadb-client -y && systemctl enable mariadb && systemctl start mariadb && mysql_secure_installation && create_new_user"; }
install_php() { install_tool "php" "apt install php libapache2-mod-php php-mysql -y"; }
install_python3() { install_tool "python3" "apt install python3 python3-pip -y"; }
install_netcat() { install_tool "nc" "apt install netcat -y"; }
install_nikto() { install_tool "nikto" "apt install nikto -y"; }
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
install_git() { install_tool "git" "apt install git -y"; }
install_curl() { install_tool "curl" "apt install curl -y"; }
install_nmap() { install_tool "nmap" "apt install nmap -y"; }
install_openssh() { install_tool "ssh" "apt install openssh-server -y && systemctl enable ssh && systemctl start ssh"; }
install_wireshark() { install_tool "wireshark" "apt install wireshark -y"; }
install_docker() { 
    if is_installed "docker"; then 
        echo "Docker is already installed."
    else 
        echo "Installing Docker..."
        apt install apt-transport-https ca-certificates curl software-properties-common -y
        curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
        apt update
        apt install docker-ce -y
        systemctl enable docker
        systemctl start docker
        echo "Docker installed."
    fi 
}
install_metasploit() { install_tool "msfconsole" "apt install metasploit-framework -y"; }
install_burp_suite() { 
    if [ -d "burpsuite" ]; then 
        echo "Burp Suite is already installed."
    else 
        echo "Installing Burp Suite..."
        wget https://portswigger.net/burp/releases/download?product=community&version=2023.8.1&type=jar -O burpsuite.jar
        echo "Burp Suite downloaded. You can run it with 'java -jar burpsuite.jar'"
    fi 
}
install_snort() { install_tool "snort" "apt install snort -y"; }
install_aircrack_ng() { install_tool "aircrack-ng" "apt install aircrack-ng -y"; }
install_john() { install_tool "john" "apt install john -y"; }
install_openvas() { 
    echo "Installing OpenVAS..."
    apt install openvas -y
    gvm-setup
    gvm-start
    echo "OpenVAS installed and started."
}
install_sqlmap() { install_tool "sqlmap" "apt install sqlmap -y"; }
install_ettercap() { install_tool "ettercap" "apt install ettercap-graphical -y"; }

# Function to create a new MariaDB user
create_new_user() {
    read -p "Enter the new username for MariaDB: " new_user
    read -sp "Enter the password for the new user: " new_password
    echo
    mysql -u root -e "CREATE USER '$new_user'@'localhost' IDENTIFIED BY '$new_password';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$new_user'@'localhost';"
    mysql -u root -e "FLUSH PRIVILEGES;"
    echo "User '$new_user' created and granted privileges."
}

# Function to display the menu
display_menu() {
    echo -e "\033[1;34mSelect tools to install (separate multiple choices with spaces):\033[0m"
    echo -e "\033[1;32m1) Apache2\033[0m"
    echo -e "\033[1;33m2) MariaDB\033[0m"
    echo -e "\033[1;35m3) PHP\033[0m"
    echo -e "\033[1;36m4) Python3\033[0m"
    echo -e "\033[1;37m5) Netcat\033[0m"
    echo -e "\033[1;31m6) Nikto\033[0m"
    echo -e "\033[1;34m7) Fluxion\033[0m"
    echo -e "\033[1;32m8) Git\033[0m"
    echo -e "\033[1;33m9) Curl\033[0m"
    echo -e "\033[1;35m10) Nmap\033[0m"
    echo -e "\033[1;36m11) OpenSSH Server\033[0m"
    echo -e "\033[1;37m12) Wireshark\033[0m"
    echo -e "\033[1;31m13) Docker\033[0m"
    echo -e "\033[1;34m14) Metasploit Framework\033[0m"
    echo -e "\033[1;32m15) Burp Suite\033[0m"
    echo -e "\033[1;33m16) Snort\033[0m"
    echo -e "\033[1;35m17) Aircrack-ng\033[0m"
    echo -e "\033[1;36m18) John the Ripper\033[0m"
    echo -e "\033[1;37m19) OpenVAS\033[0m"
    echo -e "\033[1;31m20) SQLMap\033[0m"
    echo -e "\033[1;34m21) Ettercap\033[0m"
    echo -e "\033[1;32m22) Uninstall a Tool\033[0m"
    echo -e "\033[1;33m23) Exit\033[0m"
}

# Function to print the header
print_header() {
    echo -e "\n"
    echo -e "\033[1;34m============================================================\033[0m"
    echo -e "\033[1;32m             Welcome to the Omkar WebMaster Installer      \033[0m"
    echo -e "\033[1;33m                     Created by Omkar Gore                    \033[0m"
    echo -e "\033[1;34m============================================================\033[0m\n"
}

# Check for root privileges
check_root

# Main installation loop
while true; do
    print_header
    display_menu
    echo -n -e "\n\033[1;34m============================\033[0m"
    read -p " Enter your choice (e.g., 1 2 3): " -a choices
    echo -e "\033[1;34m============================\033[0m"

    for choice in "${choices[@]}"; do
        case "$choice" in
            1) install_apache2 ;;
            2) install_mariadb ;;
            3) install_php ;;
            4) install_python3 ;;
            5) install_netcat ;;
            6) install_nikto ;;
            7) install_fluxion ;;
            8) install_git ;;
            9) install_curl ;;
            10) install_nmap ;;
            11) install_openssh ;;
            12) install_wireshark ;;
            13) install_docker ;;
            14) install_metasploit ;;
            15) install_burp_suite ;;
            16) install_snort ;;
            17) install_aircrack_ng ;;
            18) install_john ;;
            19) install_openvas ;;
            20) install_sqlmap ;;
            21) install_ettercap ;;
            22) 
                echo "Uninstalling a tool..."
                read -p "Enter the name of the tool to uninstall: " uninstall_tool
                if is_installed "$uninstall_tool"; then
                    apt remove "$uninstall_tool" -y
                    echo "$uninstall_tool has been uninstalled."
                else
                    echo "$uninstall_tool is not installed."
                fi
                ;;
            23) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid choice: $choice"; ;;
        esac
    done
done
