#!/usr/bin/python3
import os
import pwd
import sys

# Python script to create new users
# Designed to be used with Password Manager Pro or PMP
# By Nicholas Grogg

# Help Function
def helpFunction():
    print("Help")
    print("----------------------------------------------------")
    print("Create new users")
    print("")
    print("help/Help")
    print("* Displays this help message and exits")
    print("")
    print("newuser/Newuser")
    print("* Creates a new user")
    print("* Adds to apache, adm groups and restarts pmp")
    print("Ex. ./newUser.py newuser jdoe")

# Function to add user
def newUser(passedName):
    print("Add new user")
    print("----------------------------------------------------")
    print("Creating user %s" %(passedName))
    ## Check if user exists
    try:
        pwd.getpwnam(passedName)
        print("ERROR - User %s exists!" %(passedName))
        print("----------------------------------------------------")
        ### If user exists, error out
        exit("User %s exists! Re-run with different values!" %(passedName))
    ### Else create user
    except KeyError:
        print("Creating user %s" %(passedName))
        print("----------------------------------------------------")
        os.system("useradd -m "+passedName+" -s /usr/bin/bash")

    ## Add to webdev and adm groups
    print("Adding to groups")
    print("----------------------------------------------------")
    # TODO: Check if user already in group
    ### Else add user to groups
    os.system("usermod -aG adm webdev "+passedName)

    ## Add user to sudoers
    print("Adding to sudoers")
    print("----------------------------------------------------")
    # TODO: Check if user already sudoer
    ### Else add user to sudoers
    os.system("cat '"+passedName+" ALL=(ALL)ALL' >> /etc/sudoers.d/user")

    # TODO: Check if sudoers still valid
    # TODO: Capture output and grep for 'OK'
    ### If sudoers valid  restart PMP
    print("Restarting PMP to complete user creation")
    print("----------------------------------------------------")
    os.system("service pmpagent-bash-service restart")
    ### Else if sudoers invalid copy to tmp for review
    #TODO


# Parse passed input for menu
inputVar = str(sys.argv[1])

# Run help function
if inputVar == "help" or inputVar == "Help":
    ## Run help function
    helpFunction()

# Run user creation function
elif inputVar == "newuser" or inputVar == "Newuser":
    ## Check if script running as root, exit if not
    if os.geteuid() != 0:
        exit("Re-run script with root privileges")

    ## Check if username variable passed
    try:
        ### Assign username to variable and pass to function
        username = str(sys.argv[2])
    except IndexError:
        ### If username not defined, prompt user to define one
        print("ERROR - Username not defined")
        print("----------------------------------------------------")
        username = str(input("Username not defined, enter username to continue: "))

    ## Run main function
    newUser(username)

# Else exit with error
else :
    ## Else exit
    print("ERROR - Invalid input detected")
    print("----------------------------------------------------")
    print("Running help function, re-run with valid input")
    helpFunction()
