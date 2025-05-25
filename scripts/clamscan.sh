#!/usr/bin/bash

# Clamscan
# BASH script to scan directories
# By Nicholas Grogg

# TODO Expand directories as needed
# Array of directories to scan
targetDir=("/bin" "/home" "/lib" "/opt" "/sbin" "/tmp" "/usr")

# Log file to append output to
logFile="/var/log/clamav/clamscan.log"

# Create log file if it doesn't exist
if [[ ! -f /var/log/clamav/clamscan.log ]]; then
        touch /var/log/clamav/clamscan.log
fi

# Append to log, use tee to output to screen
echo "$(date +%Y%m%d) Beginning scan on ${targetDir[*]}" | tee -a "$logFile"

# For loop to scan dirs
for directory in "${targetDir[@]}"; do
        echo "Scanning $directory" | tee -a "$logFile"

        ## Scan directory, checking for malicious files
        clamscan -i -o -r "$directory" -l "$logFile"

        ## From man clamscan
        #-i, --infected
        #Only print infected files.
        #-o, --suppress-ok-results
        #Skip printing OK files
        #-r, --recursive
        #Scan directories recursively. All the subdirectories in the given directory will be scanned.
        #-l FILE, --log=FILE
        #Save scan report to FILE.

        ## Log additional output based on output of previous command
        if [[ $? -eq 0 ]]; then
                echo "Scan of $directory completed successfully." | tee -a "$logFile"
        elif [[ $? -eq 1 ]]; then
                echo "Scan of $directory found infected files." | tee -a "$logFile"
        else
                echo "Scan of $directory encountered an error." | tee -a "$logFile"
        fi

        ## Add to console line for readability
        echo ""
done

# Bookend output
echo "$(date +%Y%m%d) Finishing scan on ${targetDir[*]}" | tee -a "$logFile"
