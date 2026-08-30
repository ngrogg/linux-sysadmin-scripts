#!/usr/bin/env bash

# Logger
# BASH stub script to run secureLogAnalyzer script and to store output to log file.
# By Nicholas Grogg

# Create log dir if it doesn't exist
if [[ ! -d /var/log/secureLogAnalyzer ]]; then
    mkdir -p /var/log/secureLogAnalyzer
fi

sudo perl secureLogAnalyzer.pl | sudo tee -a /var/log/secureLogAnalyzer/secureLogAnalyzerOutput.log.$(date +%Y%m%d)
