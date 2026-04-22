#!/usr/bin/env bash

# Login Backup
# BASH script to backup /etc/shadow and /etc/passwd
# By Nicholas Grogg
# Revision: 20260422

# Set exit on error
set -e

# Does folder exist? Make it if not
if [[ ! -d /root/loginBackup/ ]]; then
        mkdir /root/loginBackup
fi

# Backup /etc/shadow and /etc/passwd
cp /etc/shadow /root/loginBackup/shadow.$(date +%Y%m%d).BK
cp /etc/passwd /root/loginBackup/passwd.$(date +%Y%m%d).BK

# Remove files older than week
find /root/loginBackup -type f -regex '^.*BK$' -mtime +7 -exec rm -f {} \;
