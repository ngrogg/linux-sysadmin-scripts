# GCP scripts

## Overview
A collection of scripts for servers hosted in the Google Cloud Project. Named without .sh as I use them in a `~/bin` folder. <br>

## Scripts
* **cloudssh**, A BASH script for connecting to GCP linux servers using the gcloud compute command.
Takes a server, zone and project for arguments. <br>
Usage, `cloudssh server zone project`<br>
* **diskList**, A BASH script for finding a disk in a project. Takes a server and project as an
argument. Useful in cases where a disk has an unusual name, such as from a snapshot restoration. <br>
Usage, `./diskList.sh SERVER PROJECT` <br>
and configured on computer. Details on installation/configuration in script comments. <br>
* **gcpRestart**, a BASH script restarting a server in a GCP project. <br>
Takes a hostname, zone and project as arguments <br>
Usage, `gcpRestart HOSTNAME ZONE PROJECT` <br>
* **kbConnect**, a BASH script for connecting or listing Kubernetes Pods in GCP <br>
To list all pods in a project pass the 'pods' argument. Can also look for
a specific pod by passing part of it's alias.<br>
Usage, `./kbConnect pods` <br>
Usage, `./kbConnect pods ALIAS` <br>
To list all ingress public IPs pass the 'ingress' argument.
Can pass an alias to look for a specific pods public IP. <br>
Usage, `./kbConnect ingress` <br>
Usage, `./kbConnect ingress ALIAS` <br>
To connect to a pod pass the 'connect' argument and the pod alias.
Passing the connect argument without passing an alias will list all the pod aliases. Copy/Paste the alias to connect from list.<br>
Usage, `./kbConnect connect` <br>
Usage, `./kbConnect connect POD` <br>
* **projectlist**, A BASH script for listing all servers in a GCP project. <br>
Takes a project as an argument. <br>
Usage, `projectlist PROJECT`<br>
* **snapshot**, A BASH script for taking a snapshot of a GCP server. Takes server name, reason for snapshot,
sysadmin initials, and project as arguments. <br>
Usage, `./snapshot.sh SERVER REASON INITIALS PROJECT` <br>
Ex. `./snapshot.sh serverName wp ng projectName` <br>
* **snapshotRemoval**, a BASH script for removing snapshots over a week old. <br>
Takes a run command and search criteria (like initials) as arguments <br>
Usage, `./snapshotRemoval run criteria` <br>
Example using my initials, `./snapshotRemoval run ng` <br?
