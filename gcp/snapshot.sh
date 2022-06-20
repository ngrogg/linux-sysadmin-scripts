#!/usr/bin/bash

# This is a bash script designed to take snapshots of GCP instances
# This script is based off a script by former employee Sebastian Blanchette
# I highly recommend adding something like the following as an alias:
# alias gsnap='bash ~/.scripts/snapshot.sh'

# Bash flag variables for the server, why it's being snapshotted, initials of the sysadmin, and the project
server=$1
purpose=$2
initials=$3
project=$4

# Help
if [[ $1 == "help" || $1 == "Help" ]]
then
	echo "Usage: gsnap server reason initials project"
	echo "ex. gsnap womensinternationalpharmacy wpupdate ngg vmr-hipaa"
	exit
fi

# Check if server was passed, prompt for a server
if [ -z $server ]
        then
         echo -n "what server would you like to snapshot? "
         read server
fi

# Fail state
if [ -z $server ]
        then
         echo "Server name not provided, bailing!"
         exit 1
fi

# Why are you taking the snapshot?
if [ -z $purpose ]
	then
	read -p "What is the purpose of this snapshot? : " purpose
fi

# Initials of whoever is taking the snapshot
if [ -z $initials ]
	then
	read -p "Please enter initials, ex. ngg : " initials
fi

# What project?
if [ -z $project ]
	then
	gcloud projects list
	read -p "Please enter the project to use: " project
fi

# Find server zone
server_zone=$(gcloud compute instances list --project $project |grep $server |awk '{print $2}'|head -n 1)

# Find server disk 
disk_name=$(gcloud compute disks list --project $project | grep $server| awk {'print $1'} | head -n 1)

# Take actual snapshot 
gcloud compute disks snapshot $disk_name --snapshot-names=$initials-$disk_name-$purpose-$(date +"%Y%m%d") --storage-location=us --zone $server_zone --project $project

if [ $? = 0 ]
        then
         echo "Have a great day!"
         exit 0
        else
         echo "Something went wrong :("
         exit 1
fi
