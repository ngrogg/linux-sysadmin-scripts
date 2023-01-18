#!/usr/bin/bash

# A BASH script to update WordPress 
# Takes a filepath as an argument
# By Nicholas Grogg

# Help function
function helpFunction(){
	echo "Help"
	echo "-----------------------------------------------"
	echo "Script to update WordPress sites"
	echo "Takes a filepath as an argument"
	echo "Usage: wpUpdate.sh FILEPATH"
	echo "Ex. ./wpUpdate.sh /var/www/html"
	exit
}

# Function to run program 
function runProgram(){
	## Checks
	echo "Pre-flight checks"
	echo "-----------------------------------------------"
	### Check if backups taken
	echo "Were backups/snapshots taken?"
	echo "Press enter once ready to proceed"
	read junkInput

	### Check if passed filepath null
	if [ -z $1 ]; then
		echo "ISSUE DETECTED - FILEPATH NULL"
		echo "-----------------------------------------------"
		echo "Provide a filepath to use"
		read filePath
	fi

	### Check if passed filepath exists
	if [ ! -d $1 ]; then
		echo "ISSUE DETECTED - FILEPATH DOESN'T EXIST"
		echo "-----------------------------------------------"
		echo "Provide a filepath to use"
		read filePath
	fi

	### If filepath is STILL null exit
	if [ -z $filePath ]; then
		echo "ISSUE DETECTED - FILEPATH NULL"
		echo "-----------------------------------------------"
		echo "Re-run script with valid filepath"
		exit
	fi

	## Update site 
	### Navigate to webroot 
	cd $filePath

	### Check if wp-cli installed 
	#### If wp-cli doesn't exist
	if [ ! -f "/usr/bin/wp" ]; then
		echo "wp-cli not installed, installing"
		echo "-----------------------------------------------"
		#### Install wp-cli if it's not
		curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

		#### Make wp-cli executable
		sudo chmod +x wp-cli.phar

		#### Move executable to path so it can be used with 'wp'
		sudo mv wp-cli.phar /usr/bin/wp
	else
		echo "wp-cli installed, moving on"
		echo "-----------------------------------------------"
	fi

	### Check if user root
	#### If root, update as root
	if [ "$EUID" -eq 0 ]; then
		echo "Updating core"
		echo "-----------------------------------------------"
		/usr/bin/wp core update --allow-root

		echo "Updating plugins"
		echo "-----------------------------------------------"
		/usr/bin/wp plugin update --allow-root --all

		echo "Updating themes"
		echo "-----------------------------------------------"
		/usr/bin/wp theme update --allow-root --all

	#### Else, update as normal
	else
		echo "Updating core"
		echo "-----------------------------------------------"
		/usr/bin/wp core update

		echo "Updating plugins"
		echo "-----------------------------------------------"
		/usr/bin/wp plugin update --all

		echo "Updating themes"
		echo "-----------------------------------------------"
		/usr/bin/wp theme update --all
	fi

}

# Main, parse passed values 
echo "WordPress Updater"
echo "-----------------------------------------------"
echo ""
echo "Checking flags passed"
echo "-----------------------------------------------"
echo ""

## Check passed values
case "$1" in 
[Hh]elp)
	echo "Running Help function"
	echo "-----------------------------------------------"
	echo ""
	helpFunction
	exit
	;;
*)
	echo "Running WordPress Updater"
	echo "-----------------------------------------------"
	echo ""
	runProgram $1
	;;
esac
