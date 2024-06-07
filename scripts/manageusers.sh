#!/usr/bin/bash

# Manage Users
# BASH script for adding/removing users
# By Nicholas Grogg

## Help function
function helpFunction(){
	printf '%s\n' \
	'Help' \
	'----------------------------------------------------' \
	' ' \
	'help/Help' \
	'* Display this help message and exit' \
	' ' \
	'add/Add' \
	'* Add SSH user' \
	'* Pass admin for sudo permissions' \
	'* Creates non-admin user otherwise ' \
	'Usage. ./manageusers.sh add jdoe' \
	'Usage. ./manageusers.sh add jdoe admin' \
	' ' \
	'remove/Remove' \
	'* Remove SSH user' \
	'* Pass home to remove home directory' \
	'* Leaves in place otherwise' \
	'Usage. ./manageusers.sh remove jdoe ' \
	'Usage. ./manageusers.sh remove jdoe home '
}

## Function to add user
function addUser(){
	printf '%s\n' \
	'Adding User' \
	'----------------------------------------------------'
    #TODO
}

## Function to remove user
function removeUser(){
	printf '%s\n' \
	'Removing User' \
	'----------------------------------------------------'
    #TODO
}

## Main, read passed flags
	printf '%s\n' \
	'Manage Users' \
	'----------------------------------------------------' \
	' ' \
	'Checking flags passed' \
	'----------------------------------------------------'

## Check passed flags
case "$1" in
[Hh]elp)
	printf '%s\n' \
	'Running Help function' \
	'----------------------------------------------------'
	helpFunction
	exit
	;;
[Aa]dd)
	printf '%s\n' \
	'Add User' \
	'----------------------------------------------------'
    addUser $2 $3
	;;
[Rr]emove)
	printf '%s\n' \
	'Remove User' \
	'----------------------------------------------------'
    removeUser $2 $3
	;;
*)
	printf '%s\n' \
	'ISSUE DETECTED - Invalid input detected!' \
	'----------------------------------------------------' \
	'Running help script and exiting.' \
	'Re-run script with valid input'
	helpFunction
	exit
	;;
esac
