# Helper scripts

## Overview
These are scripts/programs that are only useful in specialized circumstances.
Copy them over to the servers as needed, adjust comments as required and run the scripts. <br>

## Scripts
* **curltest.php**, A php script designed to test curls to an external URL.
  Primarily used for testing if a firewall is preventing an external connection.
  Usage is a matter of configuring the URL and setting the curl options as true (1) or false (0).
  The only option that doesn't follow this is if an SSL is required, a filepath will need to be added. <br>
* **dbConTestMysql.php**, A PHP script for testing MySQL connections. Fill out the
  database name, user, host and password and run the script. <br>
* **dbConTestPsql.php**, Same as the MySQL script but for Postgres. <br>
* **diskPinger**, scripts for monitoring disk space on a server.
* **fpmStatus.php**, PHP script for viewing php-fpm info for page. Place in doc root and call via curl: `curl domain.com/fpmStatus.php` <br>
  Don't forget to remove afterwards! <br>
* **loginBackup.sh**, a BASH script for backing up `/etc/shadow` and `/etc/passwd`. Keeps backups for a week, removes older backups. <br>
  Usage, just run the script. Designed for cron. <br>
* **lockMysqlUser.sh**, a BASH script for locking MySQL users. Takes a username and IP as an argument. <br>
  Usage, `./lockMysqlUser.sh lock USERNAME IP` <br>
  Ex. `./lockMysqlUser.sh lock jdoe 10.138.0.2` <br>
  Ex. `./lockMysqlUser.sh lock jdoe 127.0.0.1` <br>
  Ex. `./lockMysqlUser.sh lock jdoe localhost` <br>
* **newMysqlUser.sh**, a BASH script for creating MySQL users. Takes a username and IP as an argument. <br>
  Usage, `./newMysqlUser.sh create USERNAME IP` <br>
  Ex. `./newMysqlUser.sh create jdoe 10.138.0.2` <br>
  Ex. `./newMysqlUser.sh create jdoe 127.0.0.1` <br>
  Ex. `./newMysqlUser.sh create jdoe localhost` <br>
* **passgen.sh**, a BASH script for generating passwords. Probably not industry shattering, but good enough for most uses.<br>
  Usage, just run the script. <br>
* **phpinfoChecker.sh**, A BASH script for finding occurrences of phpinfo() in a provided docroot. <br>
  Takes a docroot as arguments. <br>
  Usage. `./phpinfoChecker.sh check DOCROOT` <br>
  Ex. `./phpinfoChecker.sh check /var/www` <br>
  In the event there are false positives script creates an exclude file at `/root/scripts/phpinfoCheck/phpinfoExclude.txt`. <br>
  Change the filepath as needed for your own configurations. <br>
  Uses explicit filepath, not directories. <br>
  I.e. `/var/www/html/public/flaggedFile.php` <br>
  Not, `/var/www/html/public` <br>
  If it doesn't exist Exclude file can be added manually or will be created by the script when run if file is not found. <br>
* **smtpTest.pl**, A perl script for testing SMTP connections on a server. Two sections to fill out.
  First is the SMTP server section, which includes the host, port, user, password and addressee.
  Second section is to fill in the email From, To, Subject and Body. Afterwards run the script. <br>
* **structureCheck**, scripts for checking for disk corruption on a server. See README.md in folder.
* **userCreation.sh**, A BASH script for creating users on Linux servers. <br>
  Arguments:
  - add/Add <br>
    Add SSH user <br>
    Pass admin for sudo permissions <br>
    Usage. `./userCreation.sh add jdoe` <br>
    Usage. `./userCreation.sh add jdoe admin` <br>
* **userRemoval.sh**, A BASH script for removing users on Linux servers.  <br>
  Arguments:
  - remove/Remove <br>
    Remove SSH user <br>
    Pass home to remove home directory <br>
    Leaves in place otherwise <br>
    Usage. `./userRemoval.sh remove jdoe` <br>
    Usage. `./userRemoval.sh remove jdoe home` <br>
* **wpInstall.sh**, a BASH script for installing WordPress on a Linux server. Has a "Web" and "Database" function in case
  the site and database are on separate servers. <br>
  For Web Server configuration: <br>
  Usage, `./wpInstall.sh web docroot` <br>
  Ex. `./wpInstall.sh web /var/www/site.com` <br>
  For Database Server configuration: <br>
  Usage, `./wpInstall.sh webIP databaseName databaseUser` <br>
  Ex. `./wpInstall.sh 10.10.0.1 site_com site_user` <br>
  For servers where the site and database files are on the same server pass localhost or 127.0.0.1 for the web server IP. <br>
* **wpUpdate.sh**, a BASH script for updating WordPress sites. Takes a site webroot as an argument. <br>
  Usage, `./wpUpdate.sh /path/to/webroot`<br>
