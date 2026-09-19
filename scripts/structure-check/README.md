# Structure Check

## Overview
* **structure_check.py**, A Python script for cron folders like `/etc/cron.daily` used to launch the structure-check.sh script below. <br>
  Usage, just run the script. <br>
* **structure-check.sh**, A BASH script for checking for disk corruption on a server.
  Takes a sender email and recipient as arugments. <br>
  Usage, `./structure-check.sh check SENDER@email.com RECIPIENT@email.com` <br>
