#!/usr/bin/bash

# This BASH script is designed to list GCP instances
# Takes argument to search for server
# Looks through all active projects with API enabled

# Variables 
server=$1
project=$2

# Help
if [[ $1 == "help" || $1 == "Help" ]]
then
	echo "instancefind server"
	echo "instancefind server project"
	exit
fi

if [ -z $server ]
then
	echo -n "Please enter a server to search for: "
	read server 
fi

if [ -z $project ]
then
# Store all gcloud projects with active API in array, grep out projects without
projectArray=(`gcloud projects list --sort-by=projectId | grep -v '839967335996\|91754344067\|864737988528\|572864598189\|864737988527\|965127404043\|418563744460\|317303048105\|190404092566\|60871096771\|57390241751\|1013535958809\|899026836580\|630302484599\|208382770503\|982138450905\|719009714738\|719009714738' | tail -n +2 | awk '{print $1}'`)

# For loop to iterate through project searching for servers
for project in "${projectArray[@]}"
do
	echo "${project}: "
	gcloud compute instances list --project="${project}" | grep $server
done

else
	gcloud compute instances list --project=$project | grep $server
fi
