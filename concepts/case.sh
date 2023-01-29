#!/usr/bin/bash

# A BASH script demonstrating cases
# By Nicholas Grogg

## Check passed values 
case "$1" in 
[Hh]elp)
	echo "Help"
	echo "-------------------------------------"
	echo "Output passed values"
	echo "./case.sh VALUE"
	;;
*)
	echo "Case demo"
	echo "-------------------------------------"
	echo "Argument passed: $1"
	;;
esac
