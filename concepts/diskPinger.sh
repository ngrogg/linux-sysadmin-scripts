#!/usr/bin/bash

# Disk Pinger
# BASH script to check disk space on a server and send an email
# By Nicholas Grogg

## Help function
function helpFunction(){
	printf "%s\n" \
	"Help" \
	"----------------------------------------------------" \
	" " \
	"help/Help" \
	"* Display this help message and exit" \
	" " \
	"run/Run" \
	"* PROGRAM DESCRIPTION " \
	"* ARGUMENTS " \
	"Ex. ./SCRIPT run ARG ARG"
}

## Function to run program
function runProgram(){
	printf "%s\n" \
	"RUN" \
	"----------------------------------------------------"
}

## Main, read passed flags
	printf "%s\n" \
	"PROGRAM NAME" \
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
[Rr]un)
	printf "%s\n" \
	"Running script" \
	"----------------------------------------------------"
	runProgram
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
