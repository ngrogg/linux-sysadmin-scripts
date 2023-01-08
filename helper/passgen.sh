#!/usr/bin/bash

# A BASH script to generate a random password based on date 
# By Nicholas Grogg 

# Assign passed value to length
length=$1

# If no value passed to length, assign a default of 30
if [ -z $length ]; then
	length=30
fi

# Generate password, append letters/numbers/symbols and output
pass=$(date +%s | sha256sum | base64 | head -c $length)
pass+=$(((RANDOM%1000+1)))
pass+="!"
echo $pass
