#!/usr/bin/bash

# User Removal
# BASH script to remove an SSH user
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
    "remove/Remove" \
    "* Remove SSH user" \
    "* Pass home to remove home directory" \
    "* Leaves in place otherwise" \
    "Usage. ./userRemoval.sh remove jdoe " \
    "Usage. ./userRemoval.sh remove jdoe home "
}

# Function to run program
function runProgram(){
	printf "%s\n" \
	"Remove" \
	"----------------------------------------------------"

    ### Variables
    #### Username to remove
    username=$1

    #### Check if home argument was passed
    if [[ $2 =~ [Hh]+[Oo]+[Mm]+[Ee] ]]; then
            removeHome="Yes"
    else
            removeHome="No"
    fi

    ### Validate user input
    #### Is user root?
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

    #### Does user exist?
    "Checking if user exists"\
    "----------------------------------------------------" \
    " "

    if [[ ! $(grep -c "$username" /etc/passwd) ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - User doesn't exist!" \
        "----------------------------------------------------" \
        "Username doesn't exist, cannot remove!${normal}"
        exit 1
    else
        printf "%s\n" \
        "${green}User exists "\
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    fi

    ### Confirmation
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Username to remove: " "$username" \
    "Remove home directory?: " "$removeHome" \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
    " "

    read junkInput

    ### Remove user and home dir if specified
    if [[ "$removeHome" == "Yes" ]]; then
            userdel -r $username
    else
            userdel $username
    fi

}

# Main, read passed flags
	printf "%s\n" \
	"User Removal" \
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
[Rr]emove)
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
