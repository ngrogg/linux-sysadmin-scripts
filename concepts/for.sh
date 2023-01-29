#!/usr/bin/bash

# For loops in BASH
# By Nicholas Grogg

## Function to run program
function runProgram(){
	echo "Main"
	echo "----------------------------------------------------"

	echo "BASH for loop"
	echo "----------------------------------------------------"
	for i in 1 2 3
	do
		echo $i
	done

	echo "BASH for loop with C style syntax"
	echo "----------------------------------------------------"
	for ((count=1; count <= 3; count++))
	do
		echo $count
	done

}

## Main, read passed flags 
echo "For loops"
echo "----------------------------------------------------"
echo ""
runProgram

