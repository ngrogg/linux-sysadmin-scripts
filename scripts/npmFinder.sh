#!/usr/bin/env bash

# NPM Finder
# BASH script to find npm installs and list modules
# By Nicholas Grogg
# Revision: 20260422

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
    "* Check server for NPM installs and list packages" \
    "* No arguments" \
    "* Script must be run as root or with sudo" \
    " " \
    "Ex. ./npmFinder.sh check"
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Check" \
    "----------------------------------------------------"

    ## Validation
    ### Check if user root
    printf "%s\n" \
    "Checking if user is root " \
    "----------------------------------------------------" \
    " "
    if [[ "$EUID" -eq 0 ]]; then
        printf "%s\n" \
        "${green}User is root " \
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - User is NOT root " \
        "----------------------------------------------------" \
        "Re-run script as root${normal}"
        exit 1
    fi


    printf "%s\n" \
    "Beginning search for npm installs" \
    "----------------------------------------------------" \
    " "

    ## Find all npm executables.
    ### Command breakdown:
    ### This skips virtual and temporary filesystems to speed search up
    ### \( -path /proc -o -path /sys -o -path /dev -o -path /run \) -prune
    ###
    ### Looks for standard executable files named "npm".
    ### -type f -name "npm" -executable
    ###
    ### Also looks for symlinks named "npm"
    ### -o -type l -name "npm"
    ###
    ### Hides any lingering permission or read errors.
    ### 2>/dev/null
    npmFilepaths=$(find / \( -path /proc -o -path /sys -o -path /dev -o -path /run \) -prune -o \( \( -type f -executable -name "npm" \) -o \( -type l -name "npm" \) \) -print 2>/dev/null)

    ## If no NPM instances found, exit
    if [[ -z "$npmFilepaths" ]]; then
      printf "%s\n" \
      "No NPM installs found..." \
      "----------------------------------------------------" \
      " "
      exit 0
    fi

    ## Check each NPM path with for loop
    for npmInstall in $npmFilepaths; do

        ### Check if the found file is actually functional by requesting its version.
        ### Some arbitrary scripts might be named "npm", helps filter false positives
        ### 2>/dev/null to capture the output and discard errors.
        npmVersion=$($npmInstall -v 2>/dev/null)

        ### If npmVersion is not empty, it's a valid npm instance
        if [[ -n "$npmVersion" ]]; then
            printf "%s\n" \
            "NPM Instance Information" \
            "----------------------------------------------------" \
            "NPM Filepath: " "$npmInstall" \
            "NPM Version: " "$npmVersion" \
            " " \
            "Packages: "

            #### Run 'npm list -g' using THIS specific executable.
            #### The '-g' flag lists the packages associated with this specific node/npm environment
            #### Use --depth=0 to keep the output readable by only showing top-level packages.
            $npmInstall list -g --depth=0 2>/dev/null
            #### TODO: Remove --depth=0 to see the entire nested dependency tree.
            #$npmInstall list -g 2>/dev/null

        fi
    done

    printf "%s\n" \
    "${green}Search Complete!" \
    "----------------------------------------------------" \
    "${normal}"

}

# Main, read passed flags
printf "%s\n" \
"NPM Finder" \
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
    runProgram
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
