#!/usr/bin/bash

# PHPinfo Checker
# BASH script to find files containing phpinfo() and sending an email
# By Nicholas Grogg

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
function helpFunction(){
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
    "Ex. ./phpinfoChecker.sh check /var/www/" \
    " " \
    "* In the event of false positives there's an exclude file." \
    "* Filepaths to exclude at" \
    "/root/scripts/phpinfoCheck/phpinfoExclude.txt" \
    " " \
    "* Use a full filepath for exclusions " \
    "Ex. /var/www/html/public/flaggedFile.php" \
    " " \
    "* Do not use a directory " \
    "Not /var/www/html/public/ " \
    " " \
    "* These make it too easy to hide matches." \
    "* Exclusion file will be created by script if it doesn't exist."
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Check" \
    "----------------------------------------------------"

    ## Assign webroot to variable
    docroot=$1

    ## Validation
    ### Does Docroot exist?
    if [[ -d $docroot ]]; then
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
    ### If working directory /root/scripts/phpinfoCheck/ doesn't exist, create directory
    if [[ ! -d /root/scripts/phpinfoCheck ]]; then
            mkdir -p /root/scripts/phpinfoCheck
    fi

    ### Create log file directory if it doesn't exist
    if [[ ! -d /var/log/phpinfoChecker ]]; then
            mkdir /var/log/phpinfoChecker
    fi

    ### If /root/scripts/phpinfoCheck/phpinfoExclude.txt doesn't exist, create and populate with first exclusion
    if [[ ! -f /root/scripts/phpinfoCheck/phpinfoExclude.txt ]]; then
            ### Populate w/ exclusions, add your own files as needed
            echo "/var/www/samplesite.com/example.php" >> /root/scripts/phpinfoCheck/phpinfoExclude.txt
    fi

    ## PHP Info check
    ### Check for phpinfo, populate interim list
    grep -r -i -l --include="*.php" "phpinfo()" $docroot > /root/scripts/phpinfoCheck/phpinfoCheckInterim.txt

    ### Remove exclusions
    #### -v select non-matching lines
    #### -x match whole lines only
    #### -f FILE get patterns from FILE
    grep -v -x -f /root/scripts/phpinfoCheck/phpinfoExclude.txt /root/scripts/phpinfoCheck/phpinfoCheckInterim.txt > /root/scripts/phpinfoCheck/phpinfoListToCheck.txt

    ### Remove interim list
    rm /root/scripts/phpinfoCheck/phpinfoCheckInterim.txt

    ### Populate fileCount variable
    #### Empty file appeared as one line via wc -l and wc -c, used wc -w for word counts to populate count
    fileCount=$(wc -w /root/scripts/phpinfoCheck/phpinfoListToCheck.txt | awk '{print $1}')

    ### If file count of list > 0, parse list and send
    if [[ $fileCount -gt 0 ]]; then
        ##### Does the file created when sending a ticket already exist?
        if [[ -e /root/scripts/phpinfoCheck/phpinfoCheckEmailSent.txt ]]; then
                ###### Check if ticket opened in the last week
                if [[ $(find /root/scripts/phpinfoCheck/phpinfoCheckEmailSent.txt -mtime +7) ]]; then
                        ####### Remove old file if not
                        rm /root/scripts/phpinfoCheck/phpinfoCheckEmailSent.txt
                ###### Else exit so recipient isn't spammed
                else
                    exit 0
                fi
        fi

        #### Log that files potentially were found
        echo "$(date +%Y%m%d) - phpinfoChecker: check for phpinfo() triggered" >> /var/log/phpinfoChecker/log-$(date +%Y%m%d).txt
        echo "$(date +%Y%m%d) - phpinfoChecker: $fileCount possible instances found" >> /var/log/phpinfoChecker/log-$(date +%Y%m%d).txt
        echo "$(date +%Y%m%d) - phpinfoChecker: See file list below" >> /var/log/phpinfoChecker/log-$(date +%Y%m%d).txt
        for file in $(cat /root/scripts/phpinfoCheck/phpinfoListToCheck.txt); do
            echo "$(date +%Y%m%d) - phpinfoChecker: $file" >> /var/log/phpinfoChecker/log-$(date +%Y%m%d).txt
        done

        #### Append main body message to list
        echo "" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "Check files listed above for phpinfo() function" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "If valid phpinfo() instance, move out of web dir and inform client" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "If not, add filepath with filename to /root/scripts/phpinfoCheck/phpinfoExclude.txt" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "Example exclusion," >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "/var/www/html/public/flaggedFile.php" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "Only explicit filepath matches accepted" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "Do not only use directory names like below," >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "/var/www/html/public" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "List is also logged on server at," >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "/var/log/phpinfoChecker/log-$(date +%Y%m%d).txt" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "For reference a phpinfo() file will look something like this:" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "<?php phpinfo(); ?>" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt

        #TODO: Add your sender and recipient as needed
        #### Open ticket
        cat /root/scripts/phpinfoCheck/phpinfoListToCheck.txt | mail -s "Possible instances of phpinfo() found on $(hostname)" -r "SENDER" recipient@example.com

        #### Update check file with date email was sent
        echo "$(date)" >> /root/scripts/phpinfoCheck/phpinfoCheckEmailSent.txt

        #### Log that email was sent
        echo "$(date +%Y%m%d) - phpinfoChecker: opened ticket for $(hostname)" >> /var/log/phpinfoChecker/log-$(date +%Y%m%d).txt

    fi

    ## Remove ListToCheck
    rm /root/scripts/phpinfoCheck/phpinfoListToCheck.txt

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
    helpFunction
    exit
    ;;
[Cc]heck)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    runProgram $2
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input${normal}"
    helpFunction
    exit
    ;;
esac
