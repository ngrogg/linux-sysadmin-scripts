# Secure Log Analyzer

## Overview
A perl script for checking `/var/log/secure` and `/var/log/auth.log` for failed logins. <br>
Will check for either log file, prefers `/var/log/secure` if both exist. <br>
Will exit if neither log file exists. <br>

## Files
* **secureLogAnalyzer.pl**, A Perl script for checking `/var/log/secure` and `/var/log/auth.log` for failed logins. <br>
  Will probably be need run as root or with sudo permissions depending on server configurations. <br>
  Usage, just run the script. <br>
* **logger.sh**, A BASH script for running the secureLogAnalyzer.pl script, making a log dir and saving output to created log folder. <br>
  Should be run in same directory as the `secureLogAnalyzer.pl` script. Should also be run as root or with sudo permissions.
