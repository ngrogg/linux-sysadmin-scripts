#!/usr/bin/bash

# A simple BASH script for demonstrating passed bash variables 
# Includes checks for NULL variables 

# Positional Variables $1, $2, and $3 refer to the variables passed as arguments
first=$1
second=$2
third=$3

# Output script name at start
echo "Flags"
echo "--------------------------------------------"

# Help
if [[ $1 == "Help" || $1 == "help" || $1 == "-h" || $1 == "--help" ]]; then
	echo "Help"
	echo "--------------------------------------------"
	echo "A BASH script for demonstrating variables"
	echo "Pass variables as BASH arguments"
	echo "Script will output variables as text"
	echo "Usage: ./flags.sh first second third"
	echo ""
	echo "To view help pass any of the following:"
	echo "-h, --help, help, Help"
	exit
fi

# Checks 
## If first, second or third are NULL
if [[ -z $first || -z $second || -z $third ]]; then
	echo "ISSUE DETECTED"
	echo "--------------------------------------------"
	echo "A variable is null, follow output below"
	## While loop while variables NULL
	while [[ -z $first || -z $second || -z $third ]]; do
		if [[ -z $first ]];then
			echo "ISSUE DETECTED"
			echo "--------------------------------------------"
			echo "First variable is null, enter value: "
			read first
		fi
		if [[ -z $second ]];then
			echo "ISSUE DETECTED"
			echo "--------------------------------------------"
			echo "Second variable is null, enter value: "
			read second
		fi
		if [[ -z $third ]];then
			echo "ISSUE DETECTED"
			echo "--------------------------------------------"
			echo "Third variable is null, enter value: "
			read third
		fi
	done
fi

# Output variables 
echo "Output"
echo "--------------------------------------------"
echo "The first variable is '$first'"
echo "The second variable is '$second'"
echo "The third variable is '$third'"

