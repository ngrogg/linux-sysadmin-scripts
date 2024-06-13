#!/usr/bin/bash

# Disk Pinger
# BASH script to check disk space on a server and send an email
# By Nicholas Grogg

# Help function
function helpFunction(){
	printf "%s\n" \
	"Help" \
	"----------------------------------------------------" \
	" " \
	"help/Help" \
	"* Display this help message and exit" \
	" " \
	"run/Run" \
	"* Run the script and check for free disk space" \
	"* Sends an email if free disk space less than 10%  " \
    "* Takes a sender and recipent as arguments" \
	"Ex. ./diskPinger.sh run sender recipient"
}

# Function to run program
function runProgram(){
	printf "%s\n" \
	"RUN" \
	"----------------------------------------------------"

    ## Validation checks
    ### Check if send blank
    ### Check if recipient blank
    ### Confirm values

    ## Check available disk space
    ### If less than 10% disk space free
    ### Navigate to root, get list of files taking up space
    cd /
    du --max-depth=5 -chax  2>&1 | grep '[0-9\.]\+G' | sort -hr | head
    ### Send email

    ### Else exit 0

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
[Rr]un)
	printf "%s\n" \
	"Running script" \
	"----------------------------------------------------"
	runProgram $2 $3
	;;
*)
	printf "%s\n" \
	"ISSUE DETECTED - Invalid input detected!" \
	"----------------------------------------------------" \
	"Running help script and exiting." \
	"Re-run script with valid input"
	helpFunction
	exit
	;;
esac
