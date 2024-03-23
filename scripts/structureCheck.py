#!/usr/bin/python3
import os

# Structure Check
# Launches the structureCheck.sh script
# By Nicholas Grogg

# TODO: Update URL before placing in /etc/cron.daily or whatever filepath
os.system("bash /path/to/structureCheck.sh check")
