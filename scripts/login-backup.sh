#!/usr/bin/env bash

# Login Backup
# BASH script to backup /etc/shadow and /etc/passwd
# By Nicholas Grogg
# Revision: 20260918

# Set exit on error
set -e

# Does folder exist? Make it if not
if [[ ! -d /root/login_backup/ ]]; then
        mkdir /root/login_backup
fi

# Backup /etc/shadow and /etc/passwd
cp /etc/shadow /root/login_backup/shadow.$(date +%Y%m%d).BK
cp /etc/passwd /root/login_backup/passwd.$(date +%Y%m%d).BK

# Remove files older than week
find /root/login_backup -type f -regex '^.*BK$' -mtime +7 -exec rm -f {} \;
