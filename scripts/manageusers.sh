#!/usr/bin/bash

# Manage Users
# BASH script for adding/removing users
# By Nicholas Grogg

# Color variables
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
normal=$(tput sgr0)

## Help function
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
	"Usage. ./manageusers.sh add jdoe" \
	"Usage. ./manageusers.sh add jdoe admin" \
	" " \
	"remove/Remove" \
	"* Remove SSH user" \
	"* Pass home to remove home directory" \
	"* Leaves in place otherwise" \
	"Usage. ./manageusers.sh remove jdoe " \
	"Usage. ./manageusers.sh remove jdoe home "
}

## Function to add user
function addUser(){
	printf "%s\n" \
	"Adding User" \
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
    if [[ $(grep -c "$username" /etc/passwd) ]]; then
            printf "%s\n" \
            "${red}ISSUE DETECTED - User already exists!" \
            "----------------------------------------------------" \
            "Username already taken, try another username!${normal}"
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

    ### Set password
    #### Generate a random string for a password
    userPass=$(date +%s | sha256sum | base64 | head -c 30)
    userPass+=$(((RANDOM%1000+1)))
    userPass+="!"

    #### Set password for user
    echo "$userPass" | passwd $username --stdin

    ### Add user to groups, expand as needed for user configuration
    useradd -aG adm $username

    ### Validate sudoer file if user created with sudo perms
    #### Add user to sudoer file
    if [[ "$addAdmin" == "Yes" ]]; then
           echo "$username ALL=(ALL)ALL" >> /etc/sudoers.d/users

           ##### Check sudoer file for validity
           validFile=$(visudo -cf /etc/sudoers.d/users)
           if [[ $(echo $validFile | grep OK) ]]; then
	            printf "%s\n" \
                "Sudoer File valid!" \
	            "----------------------------------------------------" \
                " "
           else
	            printf "%s\n" \
                "${red}ISSUE DETECTED - Error in sudoer file!" \
	            "----------------------------------------------------" \
                "File moved to /tmp/users_REVIEW for review!"
                mv /etc/sudoers.d/users /tmp/users_REVIEW
           fi

    fi

    ### Final steps
	printf "%s\n" \
	"${yellow}IMPORTANT: Final Steps" \
	"----------------------------------------------------" \
    "Following user created: " "$username" \
    "Note the password below: " "$userPass" \
    " " \
    "This will not be saved on the server" \
    "Note or set a different password and press enter when complete${normal}"
	" "

    read junkInput
}

## Function to remove user
function removeUser(){
	printf "%s\n" \
	"Removing User" \
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
    if [[ ! $(grep -c "$username" /etc/passwd) ]]; then
            printf "%s\n" \
            "${red}ISSUE DETECTED - User doesn't exist!" \
            "----------------------------------------------------" \
            "Username doesn't exist, cannot remove!${normal}"
            exit 1

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

## Main, read passed flags
	printf "%s\n" \
	"Manage Users" \
	"----------------------------------------------------" \
	" " \
	"Checking flags passed" \
	"----------------------------------------------------"

## Check passed flags
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
	"Add User" \
	"----------------------------------------------------"
    addUser $2 $3
	;;
[Rr]emove)
	printf "%s\n" \
	"Remove User" \
	"----------------------------------------------------"
    removeUser $2 $3
	;;
*)
	printf "%s\n" \
	"${red}ISSUE DETECTED - Invalid input detected!" \
	"----------------------------------------------------" \
	"Running help script and exiting." \
	"Re-run script with valid input${red}"
	helpFunction
	exit
	;;
esac
