#!/usr/bin/bash

# A BASH script to update WordPress
# Takes a filepath as an argument
# By Nicholas Grogg
# Revision: 20260119

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
    "update/Update" \
    "* Update site with wp cli" \
    "* Takes a document root as an argument" \
    "* Installs wp-cli if not found" \
    "* By default will not run as root" \
    "* If desired, see TODO comments" \
    " " \
    "Usage. ./wpUpdate.sh update /path/to/docroot" \
    "Ex. ./wpUpdate.sh update /var/www/html"
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Update" \
    "----------------------------------------------------"

    ## Variables
    filePath=$1

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

    ## Confirmation
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Hostname: " "$(hostname)" \
    " " \
    "Docroot to update: " "$filePath" \
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

        #### Get current version of wp-cli
        currentVersion=$(/usr/bin/wp --version --allow-root | grep 'WP-CLI' | awk '{print $2}')

        #### Get latest version of wp-cli
        latestVersion=$(curl --silent "https://api.github.com/repos/wp-cli/wp-cli/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

        if [[ "$currentVersion" != "$latestVersion" ]]; then
            printf "%s\n" \
            "Updating WP CLI" \
            "----------------------------------------------------"
            sudo wp cli update --allow-root
        else
            printf "%s\n" \
            "WP CLI update to date, moving on" \
            "----------------------------------------------------"
        fi
    fi

    ## Checksums
    printf "%s\n" \
    "Checksum verification" \
    "----------------------------------------------------"

    ### Plugins
    printf "%s\n" \
    "Plugin Checksums" \
    "----------------------------------------------------"

    wp plugin verify-checksums --all --path=$filePath

    ### Themes - add once wp cli supports this
    #printf "%s\n" \
    #"Theme Checksums" \
    #"----------------------------------------------------"

    ### Core
    printf "%s\n" \
    "Core Checksums" \
    "----------------------------------------------------"

    wp core verify-checksums --include-root --path=$filePath

    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Double check that above checksums look okay" \
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

    #/usr/bin/wp plugin update --all --path=$filePath --allow-root
    # TODO If planning to run as root, uncomment above and comment below
    /usr/bin/wp plugin update --all --path=$filePath

    ### Update site themes
    printf "%s\n" \
    "Updating Themes" \
    "----------------------------------------------------"

    #/usr/bin/wp theme update --all --skip-plugins --path=$filePath --allow-root
    # TODO If planning to run as root, uncomment above and comment below
    /usr/bin/wp theme update --all --skip-plugins --path=$filePath

    ## Update site core
    printf "%s\n" \
    "Updating WP Core" \
    "----------------------------------------------------"

    #/usr/bin/wp core update --skip-plugins --path=$filePath --allow-root
    # TODO If planning to run as root, uncomment above and comment below
    /usr/bin/wp core update --skip-plugins --path=$filePath
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
[Uu]pdate)
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
