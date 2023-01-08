#!/usr/bin/bash

# BASH script to list all machines in a project 

project=$1

# Help
if [[ $1 == "help" || $1 == "Help" ]]
then
	echo "projectlist PROJECT"
	exit
fi

gcloud compute instances list --project=$project

