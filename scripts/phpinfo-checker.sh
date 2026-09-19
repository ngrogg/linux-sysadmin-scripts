#!/usr/bin/env bash

# PHPinfo Checker
# BASH script to find files containing phpinfo() and sending an email
# By Nicholas Grogg
# Revision: 20260918

# Set exit on error
set -e

# Color variables
## Errors
red=$(tput setaf 1)
## Clear checks
green=$(tput setaf 2)
## User input required
yellow=$(tput setaf 3)
## Set text back to standard terminal font
normal=$(tput sgr0)


# Help function
function help_function(){
    printf "%s\n" \
    "Help" \
    "----------------------------------------------------" \
    " " \
    "help/Help" \
    "* Display this help message and exit" \
    " " \
    "check/Check" \
    "* Check docroot for files containing phpinfo()" \
    "* Takes a docroot as an argument " \
    "Ex. ./phpinfo-checker.sh check /var/www/" \
    " " \
    "* In the event of false positives there's an exclude file." \
    "* Filepaths to exclude at" \
    "/root/scripts/phpinfo-checker/phpinfo-exclude.txt" \
    " " \
    "* Use a full filepath for exclusions " \
    "Ex. /var/www/html/public/flagged-file.php" \
    " " \
    "* Do not use a directory " \
    "Not /var/www/html/public/ " \
    " " \
    "* These make it too easy to hide matches." \
    "* Exclusion file will be created by script if it doesn't exist."
}

# Function to run program
function run_program(){
    printf "%s\n" \
    "Check" \
    "----------------------------------------------------"

    ## Assign webroot to variable
    local docroot="$1"

    ## Validation
    ### Does Docroot exist?
    if [[ -d "$docroot" ]]; then
        printf "%s\n" \
        "${green}Docroot exists"  \
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - Docroot not found!" \
        "----------------------------------------------------" \
        "Check docroot and run script again! " \
        "Exiting!${normal}"

        exit 1
    fi

    ### Are there php files in provided doc root?
    #### Command breakdown
    #### Find files at docroot
    #### -type f, type regular file
    #### -iname *.php, case insensitive match for pattern '*.php'
    if [[ $(find $docroot -type f -iname *.php | wc -l) -gt 0 ]]; then
        printf "%s\n" \
        "${green}PHP files found at docroot"  \
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - No PHP files at docroot!" \
        "----------------------------------------------------" \
        "No action to take at this time! " \
        "Exiting!${normal}"

        exit 1
    fi

    ## Preparation steps
    ### If working directory /root/scripts/phpinfo-checker/ doesn't exist, create directory
    if [[ ! -d /root/scripts/phpinfo-checker ]]; then
            mkdir -p /root/scripts/phpinfo-checker
    fi

    ### Create log file directory if it doesn't exist
    if [[ ! -d /var/log/phpinfo-checker ]]; then
            mkdir /var/log/phpinfo-checker
    fi

    ### If /root/scripts/phpinfo-checker/phpinfo-exclude.txt doesn't exist, create and populate with first exclusion
    if [[ ! -f /root/scripts/phpinfo-checker/phpinfo-exclude.txt ]]; then
            ### Populate w/ exclusions, add your own files as needed
            echo "/var/www/samplesite.com/example.php" >> /root/scripts/phpinfo-checker/phpinfo-exclude.txt
    fi

    ## PHP Info check
    ### Check for phpinfo, populate interim list
    grep -r -i -l --include="*.php" "phpinfo()" $docroot > /root/scripts/phpinfo-checker/phpinfo-checker-interim.txt

    ### Remove exclusions
    #### -v select non-matching lines
    #### -x match whole lines only
    #### -f FILE get patterns from FILE
    grep -v -x -f /root/scripts/phpinfo-checker/phpinfo-exclude.txt /root/scripts/phpinfo-checker/phpinfo-checker-interim.txt > /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt

    ### Remove interim list
    rm /root/scripts/phpinfo-checker/phpinfo-checker-interim.txt

    ### Populate file_count variable
    #### Empty file appeared as one line via wc -l and wc -c, used wc -w for word counts to populate count
    local file_count=$(wc -w /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt | awk '{print $1}')

    ### If file count of list > 0, parse list and send
    if [[ $file_count -gt 0 ]]; then
        ##### Does the file created when sending a ticket already exist?
        if [[ -e /root/scripts/phpinfo-checker/phpinfo-checker-email-sent.txt ]]; then
                ###### Check if ticket opened in the last week
                if [[ $(find /root/scripts/phpinfo-checker/phpinfo-checker-email-sent.txt -mtime +7) ]]; then
                        ####### Remove old file if not
                        rm /root/scripts/phpinfo-checker/phpinfo-checker-email-sent.txt
                ###### Else exit so recipient isn't spammed
                else
                    exit 0
                fi
        fi

        #### Log that files potentially were found
        echo "$(date +%Y%m%d) - phpinfo-checker: check for phpinfo() triggered" >> /var/log/phpinfo-checker/log-$(date +%Y%m%d).txt
        echo "$(date +%Y%m%d) - phpinfo-checker: $file_count possible instances found" >> /var/log/phpinfo-checker/log-$(date +%Y%m%d).txt
        echo "$(date +%Y%m%d) - phpinfo-checker: See file list below" >> /var/log/phpinfo-checker/log-$(date +%Y%m%d).txt
        for file in $(cat /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt); do
            echo "$(date +%Y%m%d) - phpinfo-checker: $file" >> /var/log/phpinfo-checker/log-$(date +%Y%m%d).txt
        done

        #### Append main body message to list
        echo "" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "Check files listed above for phpinfo() function" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "If valid phpinfo() instance, move out of web dir and inform client" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "If not, add filepath with filename to /root/scripts/phpinfo-checker/phpinfo-exclude.txt" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "Example exclusion," >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "/var/www/html/public/flagged-file.php" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "Only explicit filepath matches accepted" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "Do not only use directory names like below," >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "/var/www/html/public" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "List is also logged on server at," >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "/var/log/phpinfo-checker/log-$(date +%Y%m%d).txt" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "For reference a phpinfo() file will look something like this:" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt
        echo "<?php phpinfo(); ?>" >> /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt

        #TODO: Add sender and recipient as needed
        #### Open ticket
        cat /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt | mail -s "Possible instances of phpinfo() found on $(hostname)" -r "SENDER" recipient@example.com

        #### Update check file with date email was sent
        echo "$(date)" >> /root/scripts/phpinfo-checker/phpinfo-checker-email-sent.txt

        #### Log that email was sent
        echo "$(date +%Y%m%d) - phpinfo-checker: opened ticket for $(hostname)" >> /var/log/phpinfo-checker/log-$(date +%Y%m%d).txt

    fi

    ## Remove -list-to-check
    rm /root/scripts/phpinfo-checker/phpinfo-list-to-check.txt

    ## Exit gracefully, probably not needed
    exit 0

}

# Main, read passed flags
    printf "%s\n" \
    "PHPinfoChecker" \
    "----------------------------------------------------" \
    " " \
    "Checking flags passed" \
    "----------------------------------------------------"

# Check passed flags
case "$1" in
[Hh]elp)
    printf "%s\n" \
    "Running Help function" \
    "----------------------------------------------------"
    help_function
    exit
    ;;
[Cc]heck)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    run_program $2
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input${normal}"
    help_function
    exit
    ;;
esac
