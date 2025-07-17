#!/usr/bin/bash

# WP AI Author Checks
# BASH script to check for WordPress plugins with AI as the author
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
    "* Check a Docroot for WordPress plugins with AI Authors" \
    "* Takes a Docroot as an argument" \
    "* Only designed for WordPress sites" \
    "* Requires WP CLI be installed" \
    "* Will install if it's not found" \
    " " \
    "Usage. ./wpAIAuthorChecks.sh check /path/to/Docroot" \
    "Ex. ./wpAIAuthorChecks.sh check /var/www/html"
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Check" \
    "----------------------------------------------------"

    ## Variables
    ### Docroot to check
    docroot=$1

    ### Array of keywords to check for, expand as needed
    aiKeywordArray=(
            "Bard"
            "ChatGPT"
            "Chatsonic"
            "Claude"
            "CoPilot"
            "Deepsink"
            "Gemini"
            "Grok"
            "Jasper"
            "Meta"
            "Mistral"
            "Perplexity"
            "Replika"
            "YouChat"
            "Zapier"
    )

    ## Validation
    ### Was a Docroot passed?
    if [[ -z $docroot ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - A docroot wasn't passed!"  \
        "----------------------------------------------------" \
        "Script needs a docroot to review." \
        "Running help function and exiting!${normal}" \
        " "

        helpFunction
        exit 1
    else
        printf "%s\n" \
        "${green}A Docroot value was passed"  \
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    fi

    ### Does Docroot exist?
    if [[ ! -d $docroot ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Docroot doesn't exist!"  \
        "----------------------------------------------------" \
        "Running help function and exiting!${normal}" \
        " "

        helpFunction
        exit 1
    else
        printf "%s\n" \
        "${green}Docroot exists"  \
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    fi

    ### Is site in Docroot a WordPress site? Is wp-config.php or other WP directories found?
    if [[ ! -f "$docroot/wp-config.php" ]] &&
       [[ ! -d "$docroot/wp-admin" ]] &&
       [[ ! -d "$docroot/wp-content" ]] &&
       [[ ! -d "$docroot/wp-includes" ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Essential WordPress files not found!"  \
        "----------------------------------------------------" \
        "Script only works on WordPress sites." \
        "Running help function and exiting!${normal}" \
        " "

        helpFunction
        exit 1
    else
        printf "%s\n" \
        "${green}WordPress wp-config.php found"  \
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    fi

    ### Is WP CLI installed? Install if not
    if [[ ! -f "/usr/bin/wp" ]]; then
        printf "%s\n" \
        "WP-CLI not installed, installing "\
        "----------------------------------------------------" \
        " "

        #### Download wp-cli from remote site
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

        #### Make wp-cli executable
        sudo chmod +x wp-cli.phar

        #### Move wp-cli to path so it can be used with 'wp'
        sudo mv wp-cli.phar /usr/bin/wp
    fi

    ### Is WP CLI up to date? Update if not
    if [[ -f "/usr/bin/wp" ]]; then
        #### Get current version of wp
        currentVersion=$(wp --version | grep 'WP-CLI' | awk '{print $2}')

        #### Get latest version of wp-cli
        latestVersion=$(curl --silent "https://api.github.com/repos/wp-cli/wp-cli/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

        #### Compare variables, update if needed
        if [[ "$currentVersion" != "$latestVersion" ]]; then
            printf "%s\n" \
            "WP-CLI out of date, updating "\
            "----------------------------------------------------" \
            " "
        else
            printf "%s\n" \
            "${green}WP-CLI up to date"  \
            "----------------------------------------------------" \
            "Proceeding${normal}" \
            " "
        fi
    fi

    ## Check sites, for each keyword in array defined above, grep for it as an Author in the matching extensions
    for keyword in "${aiKeywordArray[@]}"; do
        ### Output keyword, append to log
        echo $keyword

        ### First check w/ WP CLI, append output to log
        wp plugin list --path=$docroot --status=active --fields=name,author | grep -i $keyword

        ### Second check w/ grep, append output to log
        #### Command breakdown
        #### -r recursive
        #### -i case insensitive
        #### --include only search files matching extension, expand/retract as needed
        #### -E enable regex to match with and without spaces
        grep -r -i --include=*.{php,js,txt,md,py} -E "author:\s*$keyword" $docroot/wp-content/plugins

        ### Whitespace for output readability
        echo ""
    done
}

# Main, read passed flags
printf "%s\n" \
"WP AI Author Check" \
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
