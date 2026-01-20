#!/usr/bin/bash

# New MySQL User
# BASH script for creating a new MySQL user
# Also works on MariaDB
# By Nicholas Grogg

# Color variables
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
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
    "create/Create" \
    "* Create MySQL user" \
    "* Takes a username and IP as arguments" \
    "* Creates a username with near root permissions for management" \
    "Usage. ./newMysqlUser.sh create username web_ip" \
    " " \
    "For remote database users use remote IP:" \
    "Ex. ./newMysqlUser.sh create jdoe 10.138.1.2" \
    " " \
    "For local database users use localhost for IP:" \
    "Ex. ./newMysqlUser.sh create jdoe localhost"
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Create" \
    "----------------------------------------------------"

    ## Variables
    databaseUser=$1
    webIP=$2

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

    ### Check if web IP was passed
    if [[ -z $webIP ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - A Web IP wasn't passed!"  \
        "----------------------------------------------------" \
        "Script needs a Web IP for database user" \
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
    "Web IP: " "$webIP" \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
    " "
    read junkInput

    ### Read in password
    read -s -p "MySQL user being used to create new user: " creatorUser

    stty -echo
    read -s -p "MySQL Password for user above: " creatorPass
    stty echo

    ## Check if user exists
    ### Run query
    checkQuery=$(mysql -u root -p"$databasePass" -e "SELECT user,host FROM mysql.user WHERE user like \"$databaseUser\" AND host like \"$welshIP\"")

    ### Check if checkQuery null or not, exit if so
    if [[ $checkQuery ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - User already exists!"  \
        "----------------------------------------------------" \
        "Exiting!${normal}" \
        " "
        exit 1
    else
        printf "%s\n" \
        "${green}User doesn't exist"\
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    fi

    ## Create user
    ### Generate a user password
    userPass=$(date +%s | sha256sum | base64 | head -c 30)
    userPass+=$(((RANDOM%1000+1)))
    userPass+="!"

    #### Create user
    mysql -u $creatorUser -p"$creatorPass" -e "CREATE USER $databaseUser@$webIP IDENTIFIED BY \"$userPass\""

    ## Grant permissions
    ### Grant user permissions
    mysql -u $creatorUser -p"$creatorPass" -e "GRANT ALL ON *.* TO $databaseUser@$webIP"

    ### Flush Privileges
    mysql -u $creatorUser -p"$creatorPass" -e "FLUSH PRIVILEGES"

    printf "%s\n" \
    "${yellow}IMPORTANT: User created" \
    "----------------------------------------------------" \
    "Database User: " "$databaseUser" \
    "Web IP: " "$webIP" \
    "Password: " "$userPass" \
    " " \
    "Note user info, it will not be saved on the server!"
    "Press enter to proceed once info saved${normal}" \
    " "
    read junkInput

}

# Main, read passed flags
printf "%s\n" \
"New DB user" \
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
[Cc]reate)
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
