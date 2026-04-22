#!/usr/bin/env bash

# MariaDB Upgrader
# BASH script for upgrading MariaDB
# By Nicholas Grogg
# Revision: 20260319

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
    "upgrade/Upgrade" \
    "* Upgrade MariaDB" \
    "* Designed for RPM/DEB based servers" \
    "* Takes target MariaDB version as argument" \
    " " \
    "Usage. ./databaseTechUpgrader.sh upgrade TARGET_VERSION" \
    "Ex. ./databaseTechUpgrader.sh upgrade 11.4" \
    " " \
    "Script will alert if disk usage >75%" \
    "Will require manual confirmation to proceed" \
    " " \
    "IMPORTANT: Script will not check versions!" \
    "A version that doesn't exist won't be confirmed!" \
    "Ex. Passing MariaDB 0.007 will not be checked!" \
    "This could have unexpected results!" \
    " "
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Upgrade" \
    "----------------------------------------------------" \
    " "

    ## Variables
    ### Current version of MariaDB installed
    techCurrentVersion=$(mariadb --version | awk '{print $5}' | cut -d'.' -f1-2)
    ### Version of database tech to upgrade
    techTargetVersion=$1
    ### Variable for date script is run
    runDate=$(date +%Y%m%d)

    ## Validation
    ### Is techTargetVersion empty?
    if [[ -z $techTargetVersion ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - MariaDB Target Version null!" \
        "----------------------------------------------------" \
        "Running help script and exiting." \
        "Re-run script with valid input${normal}" \
        " "

        helpFunction
        exit 1
    else
        printf "%s\n" \
        "${green}A Target MariaDB version was passed" \
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    fi

    ### Is MariaDB or MySQL installed?
    if [[ ! $(mysql --version | grep -i mariadb) ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - MySQL installed!" \
        "----------------------------------------------------" \
        "MariaDB not found in version string!" \
        " " \
        "Script is only for MariaDB upgrades!" \
        " " \
        "Review server configurations!" \
        "Upgrade manually if needed${normal}" \
        " "
        mysql --version

        exit 1
    else
        printf "%s\n" \
        "${green}MariaDB and not MySQL is installed" \
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    fi

    ### Is disk space usage over 75%?
    #### Variable for disk usage
    ##### Breakdown for documentation as it was really late when I wrote this :)
    # df, disk free
    # -P, POSIX output, single line per filesystem
    # /, root filesystem
    # awk'action;field', make change and print field
    # NR==2, only execute action on line 2 (df -P / is multi line)
    # gsub(), global substitution
    # "%","",$5, replace all % characters with nothing, only apply to field $5
    # print $5, print field 5
    diskUsage=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')

    #### Flag if usage over 75%
    if [[ "$diskUsage" -gt 75 ]]; then
        printf "%s\n" \
        "${yellow}IMPORTANT: User Input Required" \
        "----------------------------------------------------" \
        "Disk space usage over 75% " \
        " " \
        "Check number of databases before proceeding" \
        " " \
        "Script will dump/gzip all non-system databases" \
        " " \
        "There may or may not be enough space" \
        " " \
        "Use your best judgement!" \
        " " \
        "Press enter to proceed or control + c to cancel${normal}" \
        " "

        read junkInput
    else
        printf "%s\n" \
        "${green}Disk Space usage under 75%" \
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    fi

    ## Value confirmation
    printf "%s\n" \
    "${yellow}IMPORTANT: User Input Required" \
    "----------------------------------------------------" \
    "Value Confirmation " \
    " " \
    "Hostname: " "$(hostname)" \
    " " \
    "Current MariaDB version: " "$techCurrentVersion" \
    " " \
    "Target MariaDB version:" "$techTargetVersion" \
    " " \
    "Double check that values are correct." \
    "Double check that snapshots were taken." \
    "Double check that there's enough space available" \
    " " \
    "Running from a screen session is recommended" \
    " " \
    "IMPORTANT: Script will NOT validate versions!" \
    "Do not pass something like MariaDB .0001 " \
    " " \
    "Press enter to proceed or control + c to cancel${normal}" \
    " "

    read junkInput

    ## Upgrade
    printf "%s\n" \
    "Beginning MariaDB Upgrade" \
    "----------------------------------------------------" \
    " "

    ### Back up databases
    printf "%s\n" \
    "Backing up MariaDB databases" \
    "----------------------------------------------------" \
    " "

    mkdir mariadb.dumps.$techCurrentVersion.$techTargetVersion.$runDate

    ### Generate list of databases
    #### Password
    read -p "Enter MariaDB username: " $username
    read -s -p "Enter MariaDB password: " $databasePass

    #### Write list of databases, parse out MariaDB output and system databases
    mariadb -u "$username" -p"$databasePass" -e "SHOW DATABASES;" | tail -n +2 | grep -v -E "_schema$|mysql|^sys$" > mariadb.databases.$techCurrentVersion.$techTargetVersion.$runDate.txt

    #### If word count of text file containing databases > 0, backup databases
    if [[ $(wc -w mariadb.databases.$techCurrentVersion.$techTargetVersion.$runDate.txt | awk '{print $1}') -gt 0 ]]; then
        ##### Dump + compress databases
        for database in $(cat mariadb.databases.$techCurrentVersion.$techTargetVersion.$runDate.txt); do
            mariadb-dump -u "$username" -p"$databasePass" $database > mariadb.dumps.$techCurrentVersion.$techTargetVersion.$runDate/$database.$runDate.sql
            gzip mariadb.dumps.$techCurrentVersion.$techTargetVersion.$runDate/$database.$runDate.sql
        done

    #### Else prompt user then continue
    else
        printf "%s\n" \
        "${yellow}IMPORTANT: User Input Required" \
        "----------------------------------------------------" \
        "No app databases found" \
        " " \
        "Script only found MariaDB System databases" \
        " " \
        "No database backups were created" \
        " " \
        "Script can still carry out upgrade if desired" \
        " " \
        "As a precaution open a new session and check databases" \
        " " \
        "Press enter to proceed or control + c to cancel${normal}" \
        " "

        read junkInput
    fi

    ### Back up database configs
    printf "%s\n" \
    "Backing up MariaDB configs" \
    "----------------------------------------------------" \
    " "

    mkdir mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate

    #### Back up configs if they exist - expand as needed
    if [[ -d /etc/my.cnf.d ]]; then
        cp -r /etc/my.cnf.d mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate
    fi

    if [[ -f /etc/my.cnf ]]; then
        cp /etc/my.cnf mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate
    fi

    if [[ -d /etc/mysql/ ]]; then
        cp -r /etc/mysql/ mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate
    fi

    #### Stop Database
    printf "%s\n" \
    "Stopping MariaDB service" \
    "----------------------------------------------------" \
    " "

    systemctl stop mariadb.service

    #### Remove old MariaDB database packages
    printf "%s\n" \
    "Removing old MariaDB packages" \
    "----------------------------------------------------" \
    " "

    #### If dnf
    if [[ -f /usr/bin/dnf ]]; then
        dnf remove "mariadb-*" -y

    #### Else If Apt
    elif [[ -f /usr/bin/apt ]]; then
        apt remove "mariadb-*" -y
        apt autoremove -y

    #### Else fail
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - APT and DNF not found!" \
        "----------------------------------------------------" \
        " " \
        "APT/DNF only!${normal}" \
        " "
        exit 1
    fi

    ### Check for fringe cases, remove if found
    if [[ -f /usr/bin/dnf ]]; then
        if [[ $(rpm --query --all | grep -i -E "mariadb|galera") ]]; then
            ##### Log packages
            rpm --query --all | grep -i -E "mariadb|galera" >> galeraCheck.$techCurrentVersion.$techTargetVersion.$runDate.txt
            for package in $(rpm --query --all | grep -i -E "mariadb|galera"); do
                dnf remove $package -y
            done
        fi

    #### Else If Apt
    elif [[ -f /usr/bin/apt ]]; then
        if [[ $(apt list --installed | grep -i -E "^mariadb|galera") ]]; then
            ##### Log packages
            apt list --installed | grep -i -E "^mariadb|galera" | cut -d'/' -f1 >> galeraCheck.$techCurrentVersion.$techTargetVersion.$runDate.txt
            for package in $(apt list --installed | grep -i -E "^mariadb|galera"| cut -d'/' -f1); do
                apt remove $package -y
            done
        fi

    #### Else fail
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - APT and DNF not found!" \
        "----------------------------------------------------" \
        " " \
        "APT/DNF only!${normal}" \
        " "
        exit 1
    fi

    ### Install new MariaDB database packages
    printf "%s\n" \
    "Installing new MariaDB packages" \
    "----------------------------------------------------" \
    " "

    #### If dnf
    if [[ -f /usr/bin/dnf ]]; then
        dnf install wget -y
        wget https://r.mariadb.com/downloads/mariadb_repo_setup
        chmod +x mariadb_repo_setup
        bash mariadb_repo_setup --mariadb-server-version="mariadb-$techTargetVersion"
        dnf config-manager --disable mariadb-maxscale
        dnf install MariaDB-server MariaDB-backup -y

    #### Else If Apt
    elif [[ -f /usr/bin/apt ]]; then
        apt install wget -y
        wget https://r.mariadb.com/downloads/mariadb_repo_setup
        chmod +x mariadb_repo_setup
        bash mariadb_repo_setup --mariadb-server-version="mariadb-$techTargetVersion"
        apt update
        apt install mariadb-server mariadb-backup -y

    #### Else fail
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - APT and DNF not found!" \
        "----------------------------------------------------" \
        " " \
        "APT/DNF only!${normal}" \
        " "
        exit 1
    fi

    ### Enable/start new Database
    printf "%s\n" \
    "Starting/Enabling MariaDB" \
    "----------------------------------------------------" \
    " "

    systemctl start mariadb
    systemctl enable mariadb

    ### Upgrade Database
    printf "%s\n" \
    "Running MariaDB Upgrade" \
    "----------------------------------------------------" \
    " "

    mariadb-upgrade -u "$username" -p"$databasePass"

    printf "%s\n" \
    "Reinstalling MariaDB dependencies" \
    "----------------------------------------------------" \
    " "

    ### Reinstall fringe packages if file exists
    if [[ -f galeraCheck.$techCurrentVersion.$techTargetVersion.$runDate.txt ]]; then
        #### If dnf
        if [[ -f /usr/bin/dnf ]]; then
            for package in $(cat galeraCheck.$techCurrentVersion.$techTargetVersion.$runDate.txt); do
                dnf install -y $package
            done
        #### Else If Apt
        elif [[ -f /usr/bin/apt ]]; then
            for package in $(cat galeraCheck.$techCurrentVersion.$techTargetVersion.$runDate.txt); do
                apt install -y $package
            done
        #### Else fail
        else
            printf "%s\n" \
            "${red}ISSUE DETECTED - APT and DNF not found!" \
            "----------------------------------------------------" \
            " " \
            "APT/DNF only!${normal}" \
            " "
            exit 1
        fi
    fi

    ### Check MariaDB configs vs backed up configs
    printf "%s\n" \
    "Checking new vs backed up MariaDB configs" \
    "----------------------------------------------------" \
    " "

    if [[ -f /etc/my.cnf ]]; then
        printf "%s\n" \
        "Checking my.cnf" \
        "----------------------------------------------------" \
        " "

        #### Diff files, flag if different
        if [[ $(diff /etc/my.cnf mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate/my.cnf) ]]; then
            printf "%s\n" \
            "${yellow}IMPORTANT: User Input Required" \
            "----------------------------------------------------" \
            "File differences found" \
            " " \
            "Filename " "/etc/my.cnf" \
            " " \
            "Open new SSH session" \
            " " \
            "Check new vs existing file" \
            " " \
            "Config filepath" "/etc/my.cnf" \
            " " \
            "Backup filepath" "mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate/my.cnf" \
            "Differences: ${normal}" \
            " "

            diff /etc/my.cnf mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate/my.cnf

            printf "%s\n" \
            " " \
            "${yellow}Copy over configs and restart MariaDB if needed" \
            " " \
            "Otherwise" \
            "Press enter to proceed or control + c to cancel${normal}" \
            " "

            read junkInput
        else
            printf "%s\n" \
            "${green}No differences found" \
            "----------------------------------------------------" \
            "Proceeding${normal}" \
            " "
        fi

    fi

    if [[ -d /etc/my.cnf.d ]]; then
        printf "%s\n" \
        "Checking my.cnf.d" \
        "----------------------------------------------------" \
        " "
        #### For loop to check files
        for file in $(ls mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate/my.cnf.d/); do

            ##### Diff new vs backed up files, flag if different
            if [[ $(diff /etc/my.cnf.d/$file mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate/my.cnf.d/$file) ]]; then
                printf "%s\n" \
                "${yellow}IMPORTANT: User Input Required" \
                "----------------------------------------------------" \
                "File differences found" \
                " " \
                "Filename " "$file" \
                " " \
                "Open new SSH session" \
                " " \
                "Check new vs existing file" \
                " " \
                "Config filepath" "/etc/my.cnf.d/$file" \
                " " \
                "Backup filepath" "mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate/my.cnf.d/$file" \
                "Differences: ${normal}" \
                " "

                diff /etc/my.cnf.d/$file mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate/my.cnf.d/$file

                printf "%s\n" \
                " " \
                "${yellow}Copy over configs and restart MariaDB if needed" \
                " " \
                "Otherwise" \
                "Press enter to proceed or control + c to cancel${normal}" \
                " "

                read junkInput
            else
                printf "%s\n" \
                "${green}No differences found" \
                "----------------------------------------------------" \
                "Filename " "$file" \
                " " \
                "Proceeding${normal}" \
                " "
            fi

        done
    fi

    if [[ -d /etc/mysql/ ]]; then
        printf "%s\n" \
        "Checking /etc/mysql" \
        "----------------------------------------------------" \
        " "
        #### For loop to check files
        for file in $(find mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate/mysql/ -type f -printf "%P\n"); do

            ##### Diff new vs backed up files, flag if different
            if [[ $(diff /etc/mysql/$file mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate/mysql/$file) ]]; then
                printf "%s\n" \
                "${yellow}IMPORTANT: User Input Required" \
                "----------------------------------------------------" \
                "File differences found" \
                " " \
                "Filename " "$file" \
                " " \
                "Open new SSH session" \
                " " \
                "Check new vs existing file" \
                " " \
                "Current config filepath" "/etc/mysql/$file" \
                " " \
                "Backup config filepath" "mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate/mysql/$file" \
                " " \
                "Differences: ${normal}" \
                " "

                diff /etc/mysql/$file mariadb.configs.$techCurrentVersion.$techTargetVersion.$runDate/mysql/$file

                printf "%s\n" \
                " " \
                "${yellow}Copy over configs and restart MariaDB if needed" \
                " " \
                "Otherwise" \
                "Press enter to proceed or control + c to cancel${normal}" \
                " "

                read junkInput
            else
                printf "%s\n" \
                "${green}No differences found" \
                "----------------------------------------------------" \
                "Filename " "$file" \
                " " \
                "Proceeding${normal}" \
                " "
            fi

        done
    fi

    printf "%s\n" \
    "${green}Upgrade complete" \
    "----------------------------------------------------" \
    "Check site, check that MariaDB is working correctly" \
    "${normal}" \
    "Check that output below shows correct MariaDB version:" \
    " "

    ### Output MariaDB version, should be target version if everything worked.
    mariadb --version

}

# Main, read passed flags
printf "%s\n" \
"MariaDB Upgrader" \
"----------------------------------------------------" \
" " \
"Checking flags passed" \
"----------------------------------------------------" \
" "

# Check passed flags
case "$1" in
[Hh]elp)
    printf "%s\n" \
    "Running Help function" \
    "----------------------------------------------------" \
    " "

    helpFunction
    exit
    ;;
[Uu]pgrade)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------" \
    " "

    runProgram $2
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input${normal}" \
    " "

    helpFunction
    exit
    ;;
esac
