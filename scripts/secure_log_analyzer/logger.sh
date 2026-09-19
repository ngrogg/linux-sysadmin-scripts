#!/usr/bin/env bash

# Logger
# BASH stub script to run secure_log_analyzer script and to store output to log file.
# By Nicholas Grogg
# Revision: 20260918

# Create log dir if it doesn't exist
if [[ ! -d /var/log/secure_log_analyzer ]]; then
    mkdir -p /var/log/secure_log_analyzer
fi

sudo perl secure_log_analyzer.pl | sudo tee -a /var/log/secure_log_analyzer/secure_log_analyzer_output.log.$(date +%Y%m%d)
