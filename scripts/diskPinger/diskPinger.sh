#!/usr/bin/bash

# Disk Pinger
# Checks for low disk space, sends email if found
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
	"check/Check" \
	"* Check available disk space and open a ticket " \
	"* Takes a filepath, email, percentage over as arguments" \
	"Usage. ./diskPinger.sh check FILEPATH EMAIL THRESHOLD%" \
	"Ex. ./diskPinger.sh check / jdoe@email.com 90"
}

# Function to run program
function runProgram(){
	printf "%s\n" \
	"Check" \
	"----------------------------------------------------"

    ## Validation
    ### Check if filepath passed
    if [[ -z $1 ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Filepath not provided" \
        "----------------------------------------------------" \
        "Please enter a value below.${normal}"

        #### While loop to read in filePath
        while [[ -z $filePath ]]; do
            printf "%s\n" \
            "${yellow}IMPORTANT: Enter a value for the filepath" \
            "----------------------------------------------------" \
            "Example filespaths: '/', '/mnt' " \
            " "

            read filePath
        done
    else
        #### Else set filePath to $1
        filePath=$1

        printf "%s\n" \
        "${green}Filepath set" \
        "----------------------------------------------------" \
        "Proceeding${normal}" \
	    " "
    fi

    ### Check if email passed
    if [[ -z $2 ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Email not provided " \
        "----------------------------------------------------" \
        "${normal}"

        #### While loop to read in email
        while [[ -z $email ]]; do
            printf "%s\n" \
            "${yellow}IMPORTANT: Enter a value for the email" \
            "----------------------------------------------------" \
            "Example email: 'jdoe@email.com'" \
            " "

            read email
        done
    else
        #### Else set email to $2
        email=$2

        printf "%s\n" \
        "${green}Email set" \
        "----------------------------------------------------" \
        "Proceeding${normal}" \
	    " "
    fi

    ### Check if percentage over value passed
    if [[ -z $3 ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Percentage not provided " \
        "----------------------------------------------------" \
        "${normal}"

        #### While loop to read in threshold
        while [[ -z $threshold ]]; do
            printf "%s\n" \
            "${yellow}IMPORTANT: Enter a value for the threshold" \
            "----------------------------------------------------" \
            "Example thresholds: '90', '95' " \
            " "

            read threshold
        done
    else
        #### Else set threshold to $3
        threshold=$3

        printf "%s\n" \
        "${green}Threshold set" \
        "----------------------------------------------------" \
        "Proceeding${normal}" \
	    " "
    fi

    printf "%s\n" \
    "Checking disk space" \
    "----------------------------------------------------" \
    " "

    ### Get available disk space
    availableSpace=$(df "$filePath" -h | awk 'NR==2 {print $5}' | rev | cut -c2- | rev)

    ### Check vs threshold, if percentage over threshold send email
    if [[ $(bc <<< "$availableSpace > $threshold") == "1" ]]; then
        #### Get list of files using disk space, write output to file
        cd $filePath
        du --max-depth=5 -chax  2>&1 | grep '[0-9\.]\+G' | sort -hr | head -n 10 > /root/diskPingerOutput.txt

        #### Check if file exists, useful on initial runs
        if [[ -e /root/diskPingerEmailSent.txt ]]; then
                ##### Has an email been sent in the last two weeks? If not send one
                if [[ $(find /root/diskPingerEmailSent.txt -mtime +14) ]]; then
                        ###### Remove old file
                        rm /root/diskPingerEmailSent.txt

                        ###### Make new file
                        echo "$(date)" >> /root/diskPingerEmailSent.txt

                ##### Else exit so inboxes aren't spammed
                else
                        exit 0
                fi
        fi

        #### Send email
        #TODO: Add sending agent before deploying
        cat /root/diskPingerOutput.txt | mail -s "Low Disk Space on $(hostname)" -r "SENDER" $email

        #### Make file stating email was sent
        echo "$(date)" >> /root/diskPingerEmailSent.txt

        #### Clean up output file
        rm /root/diskPingerOutput.txt
    fi
}

# Main, read passed flags
	printf "%s\n" \
	"Disk Pinger" \
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
[Cc]heck)
	printf "%s\n" \
	"Running script" \
	"----------------------------------------------------"
	runProgram $2 $3 $4
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
