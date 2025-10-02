#!/usr/bin/bash

# Clamscan
# BASH script to scan directories
# By Nicholas Grogg

# TODO Expand directories as needed
# Array of directories to scan
targetDir=("/bin" "/lib" "/opt" "/sbin" "/tmp" "/etc" "/usr" "/var" "/home")

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
        ### If clamdscan and clamscan exist, defer to clamdscan
        if [[ -f /usr/bin/clamdscan && -f /usr/bin/clamscan ]]; then
            clamdscan -i -m --fdpass "$directory" -l "$logFile"
        ### Else if clamdscan only, use clamdscan
        elif  [[ -f /usr/bin/clamdscan && ! -f /usr/bin/clamscan ]]; then
            clamdscan -i -m --fdpass "$directory" -l "$logFile"
        ### Else if clamscan only, use clamscan
        elif  [[ ! -f /usr/bin/clamdscan && -f /usr/bin/clamscan ]]; then
            clamscan -i -o -r "$directory" -l "$logFile"
        ### Else fail out
        else
            echo "Clamscan and clamdscan not found, exiting!"
            exit 1
        fi

        ## Command breakdown from man clamscan
        #-i, --infected
        #Only print infected files.
        #-o, --suppress-ok-results
        #Skip printing OK files
        #-r, --recursive
        #Scan directories recursively. All the subdirectories in the given directory will be scanned.
        #-l FILE, --log=FILE
        #Save scan report to FILE.

        ## Command breakdown from man clamdscan
        #-i, --infected
        #Only print infected files
        #-m, --multiscan
        #In the multiscan mode clamd will attempt to scan the directory contents
        #in parallel using available threads.
        #-l FILE, --log=FILE
        #Save the scan report to FILE.

        ## Log additional output based on output of previous command
        if [[ $? -eq 0 ]]; then
              echo "Scan of $directory completed successfully." | tee -a "$logFile"
        else
              echo "Scan of $directory returned non-zero message, check manually" | tee -a "$logFile"
        fi

        ## Add to console line for readability
        echo ""
done

# Bookend output
echo "$(date +%Y%m%d) Finishing scan on ${targetDir[*]}" | tee -a "$logFile"
