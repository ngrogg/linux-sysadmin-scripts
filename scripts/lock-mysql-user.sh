#!/usr/bin/env bash

# Lock MySQL User
# BASH script to lock a MySQL user
# By Nicholas Grogg
# Revision: 20260918

# Set exit on error
set -e

# Color variables
## Errors
red=$(tput setaf 1)
## Clear checks
green=$(tput setaf 2)
## User input required
yellow=$(tput setaf 3)
## Set text back to standard terminal font
normal=$(tput sgr0)


# Help function
function help_function(){
    printf "%s\n" \
    "Help" \
    "----------------------------------------------------" \
    " " \
    "help/Help" \
    "* Display this help message and exit" \
    " " \
    "lock/Lock" \
    "* Lock MySQL user " \
    "* Takes a username and web IP as arguments " \
    "* Run as root or with sudo permissions" \
    "* Can lock either remote or local database users" \
    " " \
    "For remote database users provide the remote IP:" \
    "Usage. ./lock-mysql-user.sh lock username remote_ip " \
    "Ex. ./lock-mysql-user.sh lock jdoe_root 10.138.1.2" \
    " " \
    "For local databases use localhost for IP:" \
    "Ex. ./lock-mysql-user.sh lock jdoe_root localhost "
}

# Function to run program
function run_program(){
    printf "%s\n" \
    "Lock" \
    "----------------------------------------------------"

    ## Variables
    local database_user="$1"
    local database_ip="$2"

    ## Validation
    ### Is script running as root?
    printf "%s\n" \
    "Checking if user is root "\
    "----------------------------------------------------" \
    " "
    if [[ "$EUID" -eq 0 ]]; then
        printf "%s\n" \
        "${green}User is root "\
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - User is NOT root "\
        "----------------------------------------------------" \
        "Re-run script as root${normal}"
        exit 1
    fi

    ### Check if MySQL/MariaDB installed
    if [[ ! -f $(which mysql) && ! -f $(which mariadb) ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - MySQL/MariaDB not found! "\
        "----------------------------------------------------" \
        "Cannot proceed!${normal}"
        exit 1
    else
        printf "%s\n" \
        "${green}MySQL/MariaDB is installed "\
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    fi

    ### Check if database user was passed
    if [[ -z "$database_user" ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - A Database User wasn't passed!"  \
        "----------------------------------------------------" \
        "Script needs a Database User for site." \
        "Running help function and exiting!${normal}" \
        " "

        help_function
        exit 1
    fi

    ### Check if IP was passed
    if [[ -z "$database_ip" ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - An IP wasn't passed!"  \
        "----------------------------------------------------" \
        "Script needs an IP for database user" \
        "Running help function and exiting!${normal}" \
        " "

        help_function
        exit 1
    fi

    ## Value confirmation
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Database User: $database_user" \
    "Database IP:   $database_ip" \
    " " \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
    " "

    read junk_input

    ## Read in password quietly
    read -s -p "Enter database user password: " database_pass

    ## Check if user exists
    ### Run query
    checkQuery=$(mysql -u root -p"$database_pass" -e "SELECT user,host FROM mysql.user WHERE user like \"$database_user\" AND host like \"$database_ip\"")

    ### Check if checkQuery true or not, exit if not
    if [[ $checkQuery ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - User doesn't exist!"  \
        "----------------------------------------------------" \
        "Exiting!${normal}" \
        " "
        exit 1
    else
        printf "%s\n" \
        "${green}User exists"\
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    fi

    ## Lock MySQL user
    mysql -u root -p"$database_pass" -e "ALTER USER $database_user@$database_ip ACCOUNT LOCK;"
}

# Main, read passed flags
printf "%s\n" \
"Lock MySQL User" \
"----------------------------------------------------" \
" " \
"Checking flags passed" \
"----------------------------------------------------"

# Check passed flags
case "$1" in
[Hh]elp)
    printf "%s\n" \
    "Running Help function" \
    "----------------------------------------------------"
    help_function
    exit
    ;;
[Ll]ock)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    run_program "$2" "$3"
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input${normal}"
    help_function
    exit
    ;;
esac
