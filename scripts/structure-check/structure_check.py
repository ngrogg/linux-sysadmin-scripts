#!/usr/bin/python3
import os

# Structure Check
# Launches the structureCheck.sh script
# By Nicholas Grogg

# TODO: Update filepath before placing in /etc/cron.daily or whatever cron timing is used
os.system("bash /path/to/structureCheck.sh check")
