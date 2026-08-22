#!/usr/bin/env bash

# A BASH script to update WordPress
# Takes a filepath as an argument
# By Nicholas Grogg
# Revision: 20260821

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
function helpFunction(){
    printf "%s\n" \
    "Help" \
    "----------------------------------------------------" \
    " " \
    "help/Help" \
    "* Display this help message and exit" \
    " " \
    "auto/Auto " \
    "Find and update all WP sites at /var/www with wp-cli" \
    "Minimal output/checks " \
    "Should only be run after guided update function" \
    "Can be run as root or with root perms" \
    " " \
    "Usage. ./wpUpdate.sh auto" \
    " " \
    "update/Update" \
    "* Update site with wp cli" \
    "* Takes a document root as an argument" \
    "* Installs wp-cli if not found" \
    "* Can run as root or non-root" \
    " " \
    "Usage. ./wpUpdate.sh update /path/to/docroot" \
    "Ex. ./wpUpdate.sh update /var/www/html"
}

# Function to update ALL WordPress sites at /var/www
function autoUpdate(){
    ## If wp-cli doesn't exist install it
    if [[ ! -f "/usr/local/bin/wp" ]]; then
        ### Download wp-cli
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

        ### Make wp-cli executable
        sudo chmod +x wp-cli.phar

        ### Move executable to path so it can be used with 'wp'
        sudo mv wp-cli.phar /usr/local/bin/wp

    ## Else attempt to update wp-cli
    else
        sudo /usr/local/bin/wp cli update --allow-root --yes
    fi

    ## If run as root
    if [[ "$EUID" -eq 0 ]]; then
        ### While loop to find and update WordPress sites
        while IFS= read -r -d '' filePath; do
            #### Set docroot, update site w/ wp-cli
            /usr/local/bin/wp plugin update --allow-root --all --path="$filePath"
            /usr/local/bin/wp theme update --allow-root --all --skip-plugins --path="$filePath"
            /usr/local/bin/wp core update --allow-root --skip-plugins --path="$filePath"
            /usr/local/bin/wp core update-db --allow-root --path="$filePath"
        done < <(find /var/www -maxdepth 4 -type f -name "wp-settings.php" -printf '%h\0')
    else
        ### While loop to find and update WordPress sites
        while IFS= read -r -d '' filePath; do
            #### Set docroot, update site w/ wp-cli
            /usr/local/bin/wp plugin update --all --path="$filePath"
            /usr/local/bin/wp theme update --all --skip-plugins --path="$filePath"
            /usr/local/bin/wp core update --skip-plugins --path="$filePath"
            /usr/local/bin/wp core update-db --path="$filePath"
        done < <(find /var/www -maxdepth 4 -type f -name "wp-settings.php" -printf '%h\0')
    fi

}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Update" \
    "----------------------------------------------------"

    ## Variables
    ### Filepath to Docroot
    local filePath="$1"
    ### Bool for root, default value of false
    local rootCheck=0

    ## Checks
    ### Check if filePath passed
    if [[ -z $filePath ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - FILEPATH NULL" \
        "----------------------------------------------------" \
        "Please provide a filepath to the site's docroot" \
        "Ex. /var/www/html ${normal}" \
        " "

        read filePath
    fi

    ### Fail state for filepath
    if [[ -z $filePath ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - FILEPATH NULL" \
        "----------------------------------------------------" \
        "Filepath still null!" \
        "Running help function and exiting"

        helpFunction

        exit 1
    fi

    ### Is script running as root?
    printf "%s\n" \
    "Checking if user is root "\
    "----------------------------------------------------" \
    " "
    if [[ "$EUID" -eq 0 ]]; then
        printf "%s\n" \
        "${green}User is root "\
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "

        #### Set rootCheck to true
        rootCheck=1
    else
        "${green}User is not root "\
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    fi

    ## Confirmation
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Hostname:          $(hostname)" \
    "Docroot to update: $filePath" \
    " " \
    "Double check that values are correct." \
    "Double check that snapshots were taken." \
    " " \
    "Press enter to proceed or control + c to cancel${normal}"

    read junkInput

    ## Check if wp-cli installed
    printf "%s\n" \
    "Checking if WP CLI is installed" \
    "----------------------------------------------------"

    ### If file doesn't exist
    if [[ ! -f "/usr/bin/wp" ]]; then
        printf "%s\n" \
        "WP CLI not installed, installing" \
        "----------------------------------------------------"

        #### Download wp-cli
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

        #### Make wp-cli executable
        sudo chmod +x wp-cli.phar

        #### Move executable to path so it can be used with 'wp'
        sudo mv wp-cli.phar /usr/bin/wp
    else
        printf "%s\n" \
        "WP CLI installed, checking for updates" \
        "----------------------------------------------------"

        sudo wp cli update --allow-root
    fi

    ## Checksums
    printf "%s\n" \
    "Checksum verification" \
    "----------------------------------------------------"

    ### Plugins
    printf "%s\n" \
    "Plugin Checksums" \
    "----------------------------------------------------"

    if [[ $rootCheck -eq 1 ]]; then
        wp plugin verify-checksums --all --path=$filePath --allow-root
    else
        wp plugin verify-checksums --all --path=$filePath
    fi

    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Double check that above plugin checksums look okay" \
    " " \
    "Warnings are PROBABLY okay" \
    "Use your best judgement" \
    " " \
    "Press enter to proceed or control + c to cancel${normal}"

    read junkInput

    ### Themes - add once wp cli supports this
    #printf "%s\n" \
    #"Theme Checksums" \
    #"----------------------------------------------------"

    ### Core
    printf "%s\n" \
    "Core Checksums" \
    "----------------------------------------------------"

    if [[ $rootCheck -eq 1 ]]; then
        wp core verify-checksums --include-root --path=$filePath --allow-root
    else
        wp core verify-checksums --include-root --path=$filePath
    fi


    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Double check that above core checksums look okay" \
    " " \
    "Warnings are PROBABLY okay" \
    "Use your best judgement" \
    " " \
    "Press enter to proceed or control + c to cancel${normal}"

    read junkInput

    ## Update site
    printf "%s\n" \
    "Updating site" \
    "----------------------------------------------------"

    ### Update site plugins
    printf "%s\n" \
    "Updating Plugins" \
    "----------------------------------------------------"

    if [[ $rootCheck -eq 1 ]]; then
        /usr/bin/wp plugin update --all --path=$filePath --allow-root
    else
        /usr/bin/wp plugin update --all --path=$filePath
    fi

    ### Update site themes
    printf "%s\n" \
    "Updating Themes" \
    "----------------------------------------------------"

    if [[ $rootCheck -eq 1 ]]; then
        /usr/bin/wp theme update --all --skip-plugins --path=$filePath --allow-root
    else
        /usr/bin/wp theme update --all --skip-plugins --path=$filePath
    fi

    ## Update site core
    printf "%s\n" \
    "Updating WP Core" \
    "----------------------------------------------------"

    if [[ $rootCheck -eq 1 ]]; then
        /usr/bin/wp core update --skip-plugins --path=$filePath --allow-root
    else
        /usr/bin/wp core update --skip-plugins --path=$filePath
    fi
}

# Main, read passed flags
printf "%s\n" \
"WP Update" \
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
[Aa]uto)
    autoUpdate
    ;;

[Uu]pdate)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    runProgram "$2"
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
