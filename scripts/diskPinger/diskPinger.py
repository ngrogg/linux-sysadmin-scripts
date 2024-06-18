#!/usr/bin/python3
import os

# Disk Pinger script
# Goes in /etc/cron.whatever to trigger the diskPinger.sh script
# By Nicholas Grogg

# TODO: Update path before deploying
os.system("bash /path/to/diskPinger.sh check")
