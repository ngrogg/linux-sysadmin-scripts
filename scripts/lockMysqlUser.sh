#!/usr/bin/bash

# Lock MySQL User
# BASH script to lock a MySQL user
# By Nicholas Grogg

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
function helpFunction(){
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
    "Usage. ./lockMysqlUser.sh lock username remoteIP " \
    "Ex. ./lockMysqlUser.sh lock jdoe_root 10.138.1.2" \
    " " \
    "For local databases use localhost for IP:" \
    "Ex. ./lockMysqlUser.sh lock jdoe_root localhost "
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Lock" \
    "----------------------------------------------------"

    ## Variables
    databaseUser=$1
    databaseIP=$2

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
    if [[ -z $databaseUser ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - A Database User wasn't passed!"  \
        "----------------------------------------------------" \
        "Script needs a Database User for site." \
        "Running help function and exiting!${normal}" \
        " "

        helpFunction
        exit 1
    fi

    ### Check if IP was passed
    if [[ -z $databaseIP ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - An IP wasn't passed!"  \
        "----------------------------------------------------" \
        "Script needs an IP for database user" \
        "Running help function and exiting!${normal}" \
        " "

        helpFunction
        exit 1
    fi

    ## Value confirmation
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Database User: " "$databaseUser" \
    "Database IP: " "$databaseIP" \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
    " "

    read junkInput

    ## Read in password quietly
    read -s -p "Enter database user password: " databasePass

    ## Check if user exists
    ### Run query
    checkQuery=$(mysql -u root -p"$databasePass" -e "SELECT user,host FROM mysql.user WHERE user like \"$databaseUser\" AND host like \"$databaseIP\"")

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
    mysql -u root -p"$databasePass" -e "ALTER USER $databaseUser@$databaseIP ACCOUNT LOCK;"
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
    helpFunction
    exit
    ;;
[Ll]ock)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    runProgram $2 $3
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input${normal}"
    helpFunction
    exit
    ;;
esac
