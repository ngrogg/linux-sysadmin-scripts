#!/usr/bin/bash

# User Creation
# BASH script to add an SSH user
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
    "add/Add" \
    "* Add SSH user" \
    "* Pass admin for sudo permissions" \
    "* Creates non-admin user otherwise " \
    "Usage. ./userCreation.sh add jdoe" \
    "Usage. ./userCreation.sh add jdoe admin" \
    " "
}

# Function to run program
function runProgram(){
	printf "%s\n" \
	"Add" \
	"----------------------------------------------------"

    ### Variables
    #### Username to add
    username=$1

    #### Check if Admin value was passed
    if [[ $2 =~ [Aa]+[Dd]+[Mm]+[Ii]+[Nn] ]]; then
            addAdmin="yes"
    else
            addAdmin="no"
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

    #### Does user already exist?
    printf "%s\n" \
    "Checking if user already exists"\
    "----------------------------------------------------" \
    " "

    if [[ $(grep "$username" /etc/passwd) ]]; then
            printf "%s\n" \
            "${red}ISSUE DETECTED - User already exists!" \
            "----------------------------------------------------" \
            "Username already exists, try another username!${normal}"
            exit 1
    fi

    ### Confirmation
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Username to add: " "$username" \
    "Should user be admin?: " "$addAdmin" \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
    " "

    read junkInput

    ### Add user
    useradd -m $username -s /usr/bin/bash

    ### Add user to groups, expand as needed for user configuration
    usermod -aG adm $username

    ### Validate sudoer file if user created with sudo perms
    #### Add user to sudoer file
    if [[ "$addAdmin" == "yes" ]]; then
           echo "$username ALL=(ALL) ALL" >> /etc/sudoers.d/clients

           ##### Check sudoer file for validity
           validFile=$(visudo -cf /etc/sudoers.d/clients)
           if [[ $(echo $validFile | grep OK) ]]; then
                printf "%s\n" \
                "Sudoer File valid!" \
                "----------------------------------------------------" \
                " "
           else
                printf "%s\n" \
                "${red}ISSUE DETECTED - Error in sudoer file!" \
                "----------------------------------------------------" \
                "File moved to /tmp/clients_REVIEW for review!"
                mv /etc/sudoers.d/clients /tmp/clients_REVIEW
           fi

    fi

    ### Final steps
    printf "%s\n" \
    "${yellow}IMPORTANT: Final Steps" \
    "----------------------------------------------------" \
    "Following user created: " "$username" \
    " " \
    "Set/Share password as needed${normal}" \
    " "

}

# Main, read passed flags
	printf "%s\n" \
	"User Creation" \
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
[Aa]dd)
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
