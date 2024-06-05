#!/usr/bin/bash

# New DB User
# BASH script for creating a new database user
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
	"Usage. ./newdbuser.sh create username welsh_ip" \
	"Ex. ./newdbuser.sh create jdoe 10.138.1.2"
}

# Function to run program
function runProgram(){
	printf "%s\n" \
	"Create" \
	"----------------------------------------------------"

    ## Variables
    databaseUser=$1
    welshIP=$2

    #TODO
    ### Read in password
    #databasePass

    ## Validation for username/IP, checking if user is root
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

    ### Check if welsh IP was passed
    if [[ -z $welshIP ]]; then
	    printf "%s\n" \
        "${red}ISSUE DETECTED - A Welsh IP wasn't passed!"  \
	    "----------------------------------------------------" \
        "Script needs a Welsh IP for database user" \
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
    "Welsh IP: " "$welshIP" \
	"If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
	" "
    read junkInput

    ## Create user
    ### Generate a user password
    userPass=$(date +%s | sha256sum | base64 | head -c 30)
    userPass+=$(((RANDOM%1000+1)))
    userPass+="!"

    #### Create user
    mysql -u root -p"$databasePass" -e "CREATE USER $databaseUser@$welshIP IDENTIFIED BY \"$userPass\""

    ## Grant permissions
    ### Grant user permissions
    mysql -u root -p"$databasePass" -e "GRANT ALL ON *.* TO $databaseUser@$welshIP"

    ### Flush Privileges
    mysql -u root -p"$databasePass" -e "FLUSH PRIVILEGES"

    ## Log username/password, output to screen
    echo "$(date)" >> /root/WordPressOutput.log
    echo "Username: $databaseUser" >> /root/newdbuserOutput.log
    echo "Password: $userPass" >> /root/newdbuserOutput.log

    tail -n 3 /root/newdbuserOutput.log

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