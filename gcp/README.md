# GCP scripts

## Overview 
A collection of scripts for servers hosted in the Google Cloud Project. Named without .sh as I use them in a `~/bin` folder. <br>

## Scripts 
**diskList.sh**, A BASH script for finding a disk in a project. Takes a server and project as an 
argument. Useful in cases where a disk has an unusual name, such as from a snapshot restoration. <br>
Usage, `./diskList.sh SERVER PROJECT` <br>
and configured on computer. Details on installation/configuration in script comments. <br>
**snapshot.sh**, A BASH script for taking a snapshot of a GCP server. Takes server name, reason for snapshot,
sysadmin initials, and project as arguments. <br>
Usage, `./snapshot.sh SERVER REASON INITIALS PROJECT` <br>
Ex. `./snapshot.sh cjfe-welsh wp ngg vmr-hipaa` <br>
**cloudssh.sh**, A BASH script for connecting to GCP linux servers using the gcloud compute command. 
Takes a server, zone and project for arguments. <br>
Usage, `cloudssh server zone project`<br>
**projectlist.sh**, A BASH script for listing all servers in a GCP project.
Takes a project as an argument. <br>
Usage, `projectlist PROJECT`<br>

