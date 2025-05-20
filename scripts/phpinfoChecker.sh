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
	"* Takes a docroot as arguments " \
	"Ex. ./phpinfoChecker.sh check /var/www/" \
	" " \
	"* In the event there's false positives there's an exclude file." \
	"* Filepaths to exclude at /root/scripts/phpinfoCheck/phpinfoExclude.txt" \
	"Ex. /var/www/html/public/flaggedFile.php" \
	"Not /var/www/html/public/ " \
	" " \
	"* Not using whole directories, makes it too easy to hide matches." \
	"* File will be added by script on running if it doesn't exist."
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
    fi

    ## If working directory /root/scripts/phpinfoCheck/ doesn't exist, create directory
    if [[ ! -d /root/scripts/phpinfoCheck ]]; then
            mkdir -p /root/scripts/phpinfoCheck
    fi

    ## If /root/scripts/phpinfoCheck/phpinfoExclude.txt doesn't exist, create and populate with first exclusion
    if [[ ! -f /root/scripts/phpinfoCheck/phpinfoExclude.txt ]]; then
            ### Populate w/ exclusions, add your own files as needed
            echo "/var/www/samplesite.com/example.php" >> /root/scripts/phpinfoCheck/phpinfoExclude.txt
    fi

    ## Check for phpinfo, populate interim list
    grep -r -i -l --include="*.php" "phpinfo()" $docroot > /root/scripts/phpinfoCheck/phpinfoCheckInterim.txt

    ## Remove exclusions
    ### -v select non-matching lines
    ### -x match whole lines only
    ### -f FILE get patterns from FILE
    grep -v -x -f /root/scripts/phpinfoCheck/phpinfoExclude.txt /root/scripts/phpinfoCheck/phpinfoCheckInterim.txt > /root/scripts/phpinfoCheck/phpinfoListToCheck.txt

    ## Remove interim list
    rm /root/scripts/phpinfoCheck/phpinfoCheckInterim.txt

    ## If word count of list > 0, parse list and send
    ## Empty file appeared as one line via wc -l and wc -c, used wc -w for word counts
    if [[ $(wc -w /root/scripts/phpinfoCheck/phpinfoListToCheck.txt | awk '{print $1}') -gt 0 ]]; then
        ### Does the file created when sending a ticket exist?
        if [[ -e /root/scripts/phpinfoCheck/phpinfoCheckEmailSent.txt ]]; then
                #### Check if ticket opened in the last week
                if [[ $(find /root/scripts/phpinfoCheck/phpinfoCheckEmailSent.txt -mtime +7) ]]; then
                        ##### Remove old file if so
                        rm /root/scripts/phpinfoCheck/phpinfoCheckEmailSent.txt
                #### Else exit so emails aren't spammed
                else
                    exit 0
                fi
        fi

        ### Append directions message
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
        echo "For reference a phpinfo() file will look something like this:" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt
        echo "<?php phpinfo(); ?>" >> /root/scripts/phpinfoCheck/phpinfoListToCheck.txt

        #TODO: Add your sender and recipient as needed
        ### Open ticket
        cat /root/scripts/phpinfoCheck/phpinfoListToCheck.txt | mail -s "Possible instances of phpinfo() found on $(hostname)" -r "SENDER" recipient@example.com

        ## Update file stating email was sent
        echo "$(date)" >> /root/scripts/phpinfoCheck/phpinfoCheckEmailSent.txt

    fi

    ## Remove ListToCheck
    rm /root/scripts/phpinfoCheck/phpinfoListToCheck.txt

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
