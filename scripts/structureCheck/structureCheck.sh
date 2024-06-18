#!/usr/bin/bash

# Structure check
# Checks logs for 'Structure needs cleaning' message, send email if found
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
	'check/Check' \
	'* Check system logs for Structure needs cleaning message' \
	'* If message found sends ticket to provided address' \
	'* Pass email address and recipient as argument' \
    'Usage, ./structureCheck.sh check sender recipient'
}

## Function to run program
function runProgram(){
	printf '%s\n' \
	'Check' \
	'----------------------------------------------------'

	### Check if using syslog (DEB) or messages (RPM)
	if [[ -e /var/log/syslog ]]; then
		syslog="syslog"
	elif [[ -e /var/log/messages ]]; then
		syslog="messages"
	else
		#### This message shouldn't be reachable with most RPM/DEB configs and may suggest a more serious issue
		echo "ERROR: Unable to find syslog or messages file, check server"
		exit 1
	fi

	### Grep through messages looking for specific message, count occurrences
	check=$(grep -i 'structure needs cleaning' /var/log/$syslog | wc -l)

	### Check if ticket was already opened within last month
	if [[ -e /root/notified.txt ]]; then
		#### Check file age
		##### If file modify date older than a month remove it
		if [[ $(find /root/notified.txt -mtime +30) ]]; then
			rm /root/notified.txt
		##### Else exit so inbox isn't spammed with tickets
		else
			exit
		fi
	fi

	### If check returns more than zero, send email
	if [[ "$check" -gt "0" ]]; then
		echo "$check instance(s) of structure needs cleaning message found in server $(hostname) syslog, review required" | mail -s "Structure needs cleaning message found on $(hostname)" -r"$1" $2

		#### Create file to prevent emails from constantly being sent by cron
		echo "$(date)" >> /root/notified.txt
	fi
}

## Main, read passed flags
	printf '%s\n' \
	'Structure Check' \
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
[Cc]heck)
	printf '%s\n' \
	'Running script' \
	'----------------------------------------------------'
	runProgram $2 $3
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
