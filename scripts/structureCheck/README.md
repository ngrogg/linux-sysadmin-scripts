# Structure Check
## Overview
* **structureCheck.py**, A Python script for cron folders like `/etc/cron.daily` used to launch the structureCheck.sh script below. <br>
  Usage, just run the script. <br>
* **structureCheck.sh**, A BASH script for checking for disk corruption on a server.
  Takes a sender email and recipient as arugments. <br>
  Usage, `./structureCheck.sh check SENDER@email.com RECIPIENT@email.com` <br>
