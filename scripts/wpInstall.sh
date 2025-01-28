#!/usr/bin/bash

# WordPress Install
# BASH script to install WordPress
# By Nicholas Grogg

# Color variables
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
normal=$(tput sgr0)

# Help function
function helpFunction(){
	printf "%s\n" \
	"Help" \
	"----------------------------------------------------" \
	" " \
	"help/Help" \ "* Display this help message and exit" \
	" " \
	"web/Web" \
	"* Install WordPress site on web server" \
	"* Takes a site docroot as an argument " \
    "* IMPORTANT: Does NOT create apache vhost! " \
	"Usage. ./wpInstall.sh web docroot" \
	"Ex. ./wpInstall.sh web /var/www/site.com" \
	" " \
	"database/database" \
	"* Create Database and Database user on database server" \
	"* Takes Web IP, Database name and database user as arguments " \
	"Usage. ./wpInstall.sh database webIP databaseName databaseUser" \
	"Ex. ./wpInstall.sh database 10.10.0.1 site_com site_user"
}

# Function to install WordPress on Web
function web(){
	printf "%s\n" \
	"Web Configure" \
	"----------------------------------------------------"

    ## Variables
    ### Webroot to install
    webroot=$1

    ### Is server DEB or RPM based?
	### Check if using apt (DEB) or yum (RPM), set syslog based on output
	if [[ -e /usr/bin/yum ]]; then
		syslog="messages"
	elif [[ -e /usr/bin/apt ]]; then
		syslog="syslog"
	else
		#### This message shouldn't be reachable with our configs and may suggest a more serious issue
		printf "%s\n" \
		"${red}ISSUE DETECTED - This shouldn't be reachable! "\
		"----------------------------------------------------" \
		"messages and syslog not found, review server!${normal}"
		exit 1
	fi

    ## Validation
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
	else
		printf "%s\n" \
		"${red}ISSUE DETECTED - User is NOT root "\
		"----------------------------------------------------" \
		"Re-run script as root${normal}"
		exit 1
	fi

    ### Was a webroot passed?
    if [[ -z $webroot ]]; then
	    printf "%s\n" \
        "${red}ISSUE DETECTED - A webroot wasn't passed!"  \
	    "----------------------------------------------------" \
        "Script needs a webroot to install site to." \
        "Running help function and exiting!${normal}" \
        " "

        helpFunction
        exit 1
    else
	    printf "%s\n" \
        "${green}A Webroot value was passed"  \
	    "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    fi

    ## Value confirmation
	printf "%s\n" \
	"${yellow}IMPORTANT: Value Confirmation" \
	"----------------------------------------------------" \
    "Webroot: " "$webroot" \
	"If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
	" "
    read junkInput

    ## Check for php-mysql, install if missing
	printf "%s\n" \
	"Checking for PHP MySQL "\
	"----------------------------------------------------"
    " "
    if [[ ! $(php -m | grep mysql) ]]; then
            if [[ -e /usr/bin/yum ]]; then
                    sudo yum install php-mysqlnd -y
            elif [[ -e /usr/bin/apt ]]; then
                    sudo apt install php-mysql -y
            else
                #### This message shouldn't be reachable with our configs and may suggest a more serious issue
                printf "%s\n" \
                "${red}ISSUE DETECTED - This shouldn't be reachable! "\
                "----------------------------------------------------" \
                "messages and syslog not found, review server!${normal}"
                exit 1
            fi
    fi

    ## Install WordPress
    ### Check if webroot exists
    if [[ -d $webroot ]]; then
            ### Navigate to provided webroot
            cd $webroot
    ### If not, create directory and navigate to it
    else
            mkdir -p $webroot
            cd $webroot
    fi

    ### Pull in and unpack wordpress files
    wget https://wordpress.org/latest.zip
    unzip latest.zip
    mv wordpress/* .
    rm -rf latest.zip wordpress/

    ### Create upload folder
    mkdir -p wp-content/uploads
    cd ../../

    ### Loosen permissions
    chmod 775 $(pwd) -R
    if [[ "$syslog" == "yum" ]]; then
        chown apache:webdev $(pwd) -R
    else
        chown www-data:webdev $(pwd) -R
    fi

    ## Prompt user on next steps
	printf "%s\n" \
	"${yellow}IMPORTANT: Web function complete" \
	"----------------------------------------------------" \
	"WordPress files in place" \
    "If not already done, create a virtualhost" \
    "Run database function next on database server next${normal}"
}

# Function to create database/database user on database
function database(){
	printf "%s\n" \
	"database Configure" \
	"----------------------------------------------------"

    ## Variables
    webIP=$1
    databaseName=$2
    databaseUser=$3

    ## Validation
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
	else
		printf "%s\n" \
		"${red}ISSUE DETECTED - User is NOT root "\
		"----------------------------------------------------" \
		"Re-run script as root${normal}"
		exit 1
	fi

    ### Check if web IP was passed
    if [[ -z $webIP ]]; then
	    printf "%s\n" \
        "${red}ISSUE DETECTED - A Web IP wasn't passed!"  \
	    "----------------------------------------------------" \
        "Script needs a Web IP for database user" \
        "Running help function and exiting!${normal}" \
        " "

        helpFunction
        exit 1
    fi

    ### Check if database name was passed
    if [[ -z $databaseName ]]; then
	    printf "%s\n" \
        "${red}ISSUE DETECTED - A Database Name wasn't passed!"  \
	    "----------------------------------------------------" \
        "Script needs a database for site." \
        "Running help function and exiting!${normal}" \
        " "

        helpFunction
        exit 1
    fi

    ### Check if database user was passed
    if [[ -z $databaseUser ]]; then
	    printf "%s\n" \
        "${red}ISSUE DETECTED - A Database User wasn't passed!"  \
	    "----------------------------------------------------" \
        "Script needs a Database User for site." \
        "Running help function and exiting!${normal}" \
        " "

        helpFunction
        exit 1
    fi

    ## Value confirmation
	printf "%s\n" \
	"${yellow}IMPORTANT: Value Confirmation" \
	"----------------------------------------------------" \
    "Web IP: " "$webIP" \
    "Database Name: " "$databaseName" \
    "Database User: " "$databaseUser" \
	"If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
	" "
    read junkInput

    ## Parse MySQL root password from .mypass
    read -s -p "MySQL Password: " databasePass

    ## Create user/database and grant permissions
    ### Create WordPress Database
    mysql -u root -p"$databasePass" -e "CREATE DATABASE $databaseName"

    ### Create WordPress User
    #### Generate a random password and store it
    userPass=$(date +%s | sha256sum | base64 | head -c 30)
    userPass+=$(((RANDOM%1000+1)))
    userPass+="!"

    #### Create user
    mysql -u root -p"$databasePass" -e "CREATE USER $databaseUser@$webIP IDENTIFIED BY \"$userPass\""

    ### Grant user permissions
    mysql -u root -p"$databasePass" -e "GRANT ALL ON $databaseName.* TO $databaseUser@$webIP"

    ### Flush Privileges
    mysql -u root -p"$databasePass" -e "FLUSH PRIVILEGES"

    ### Write output to text file, append in case script is run multiple times
    echo "$(date)" >> /var/log/WordPressOutput.log
    echo "Database Name: $databaseName" >> /var/log/WordPressOutput.log
    echo "Username: $databaseUser" >> /var/log/WordPressOutput.log
    echo "Password: $userPass" >> /var/log/WordPressOutput.log
    echo "Database Host: $(hostname -I)" >> /var/log/WordPressOutput.log

    ## Prompt user on next steps
	printf "%s\n" \
	"${yellow}IMPORTANT: database function complete" \
	"----------------------------------------------------" \
	"WordPress database and user created" \
    "If not already done, add hostfile entry for site" \
    "Load site in browser and finish install" \
    "Use values listed below for install prompts.${normal}" \
    " "

    ## Output WordPress log for copying
    cat /var/log/WordPressOutput.log
}

# Main, read passed flags
	printf "%s\n" \
	"WordPress Install" \
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
[Ww]eb)
	printf "%s\n" \
	"Running script" \
	"----------------------------------------------------"
    web $2
	;;
[Dd]atabase)
	printf "%s\n" \
	"Running script" \
	"----------------------------------------------------"
    database $2 $3 $4
	;;
*)
	printf "%s\n" \
	"ISSUE DETECTED - Invalid input detected!" \
	"----------------------------------------------------" \
	"Running help script and exiting." \
	"Re-run script with valid input"
	helpFunction
	exit
	;;
esac
