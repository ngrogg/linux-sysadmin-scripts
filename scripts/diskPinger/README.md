# Disk Pinger

## Overview
BASH script designed to check for low disk space and to send an email if found.

## Files
* **diskPinger.py**, A Python stub script designed to launch the diskPinger.sh script.  <br>
  Designed to go in one of the `/etc/cron.*` folders. <br>
  Usage, just run the script. Be sure to update the filepath under TODO section before deploying.
* **diskPinger.sh**, A BASH script designed to check for disk space and send an email if the provided threshold is passed. <br>
  Takes a filepath, email and percentage as arguments. <br>
  A later iteration will use devices instead of filepaths. <br>
  Usage. `./diskPinger.sh check FILEPATH EMAIL THRESHOLD%` <br>
  Ex. `./diskPinger.sh check / jdoe@email.com 90` <br>
  Be sure to configure mailing agent under TODO section.
