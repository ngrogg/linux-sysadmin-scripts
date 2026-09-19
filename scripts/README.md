# Helper scripts

## Overview
These are scripts/programs that are only useful in specialized circumstances.
Copy them over to the servers as needed, adjust comments as required and run the scripts. <br>

## Scripts
* **apache_error_summarizer.pl**, A Perl script for viewing Apache errors logs and summarizing the most common errors.
  Does not list IPs. Does not check rotated logs. <br>
  Usage, `./apache_error_summarizer.pl --top #` <br>
  Ex. `./apache_error_summarizer.pl --top 15` <br>
  Also has a `--help` function.
* **curl-test.php**, A php script designed to test curls to an external URL.
  Primarily used for testing if a firewall is preventing an external connection.
  Usage is a matter of configuring the URL and setting the curl options as true (1) or false (0).
  The only option that doesn't follow this is if an SSL is required, a filepath will need to be added. <br>
* **db-con-test-mysql.php**, A PHP script for testing MySQL connections. Fill out the
  database name, user, host and password and run the script. <br>
* **db-con-test-psql.php**, Same as the MySQL script but for Postgres. <br>
* **disk-pinger**, scripts for monitoring disk space on a server.
* **fpm-status.php**, PHP script for viewing php-fpm info for page. Place in doc root and call via curl: `curl domain.com/fpm-status.php` <br>
  Don't forget to remove afterwards! <br>
* **lock-mysql-user.sh**, a BASH script for locking MySQL users. Takes a username and IP as an argument. <br>
  Usage, `./lock-mysql-user.sh lock USERNAME IP` <br>
  Ex. `./lock-mysql-user.sh lock jdoe 10.138.0.2` <br>
  Ex. `./lock-mysql-user.sh lock jdoe 127.0.0.1` <br>
  Ex. `./lock-mysql-user.sh lock jdoe localhost` <br>
* **login-backup.sh**, a BASH script for backing up `/etc/shadow` and `/etc/passwd`. Keeps backups for a week, removes older backups. <br>
  Usage, just run the script. Designed for cron. <br>
* **mariadb-upgrader.sh**, A BASH script for upgrading mariadb on servers.
  Takes a target version as an argument. Dumps and compresses non-system databases, then upgrades MariaDB. <br>
  Will flag if disk space is over 75%. <br>
  Usage, `./mariadb-upgrader.sh upgrade TARGET_VERSION` <br>
  Ex. `./mariadb-upgrader.sh upgrade 11.4` <br>
* **new-mysql-user.sh**, a BASH script for creating MySQL users. Takes a username and IP as an argument. <br>
  Usage, `./new-mysql-user.sh create USERNAME IP` <br>
  Ex. `./new-mysql-user.sh create jdoe 10.138.0.2` <br>
  Ex. `./new-mysql-user.sh create jdoe 127.0.0.1` <br>
  Ex. `./new-mysql-user.sh create jdoe localhost` <br>
* **nginx_error_summarizer.pl**, A version of the `Apache Error Checker` for Nginx. Functions more or less the same.
* **npm-finder.sh**, A BASH script for finding npm installs on servers. Must be run as root or with sudo. <br>
  Usage, `sudo ./npm-finder.sh check` <br>
  Also has a help function. <br>
* **passgen.sh**, a BASH script for generating passwords. Probably not industry shattering, but good enough for most uses.<br>
  Usage, just run the script. <br>
* **phpinfo-checker.sh**, A BASH script for finding occurrences of phpinfo() in a provided docroot. <br>
  Takes a docroot as arguments. <br>
  Usage. `./phpinfo-checker.sh check DOCROOT` <br>
  Ex. `./phpinfo-checker.sh check /var/www` <br>
  In the event there are false positives script creates an exclude file at `/root/scripts/phpinfoCheck/phpinfoExclude.txt`. <br>
  Change the filepath as needed for your own configurations. <br>
  Uses explicit filepath, not directories. <br>
  I.e. `/var/www/html/public/flaggedFile.php` <br>
  Not, `/var/www/html/public` <br>
  If it doesn't exist Exclude file can be added manually or will be created by the script when run if file is not found. <br>
* **run-clamscan.sh**, A BASH script for running clamscans on directories. Designed for crons.
  Usage, just run the script.
* **secure-log-analyzer**, A Perl script for checking `/var/log/secure` and `/var/log/auth.log` for failed logins.
  See README.md in folder for more information.
* **smtp_test.pl**, A perl script for testing SMTP connections on a server. Two sections to fill out.
  First is the SMTP server section, which includes the host, port, user, password and addressee.
  Second section is to fill in the email From, To, Subject and Body. Afterwards run the script. <br>
* **structure-check**, scripts for checking for disk corruption on a server. See README.md in folder.
* **user-creation.sh**, A BASH script for creating users on Linux servers. <br>
  Arguments:
  - add/Add <br>
    Add SSH user <br>
    Pass admin for sudo permissions <br>
    Usage. `./user-creation.sh add jdoe` <br>
    Usage. `./user-creation.sh add jdoe admin` <br>
* **user-removal.sh**, A BASH script for removing users on Linux servers.  <br>
  Arguments:
  - remove/Remove <br>
    Remove SSH user <br>
    Pass home to remove home directory <br>
    Leaves in place otherwise <br>
    Usage. `./user-removal.sh remove jdoe` <br>
    Usage. `./user-removal.sh remove jdoe home` <br>
* **wp-ai-author-checks.sh**, A BASH script for checking WordPress sites for plugins authored by AI.
  Should at least catch the lazily made ones with the AI chat listed as an author. <br>
  Arguments: <br>
  - **help**, Display help message and exit
  - **check**, Check a provided Docroot for WordPress plugins with AI listed as the author.
    `Usage. ./wp-ai-author-checks.sh check /path/to/docroot`
    `Ex. ./wp-ai-author-checks.sh check /var/www/html`
  Requirements: <br>
  Requires WP CLI be installed. Will install if it's not. <br>
* **wp-install.sh**, a BASH script for installing WordPress on a Linux server. Has a "Web" and "Database" function in case
  the site and database are on separate servers. <br>
  For Web Server configuration: <br>
  Usage, `./wp-install.sh web docroot` <br>
  Ex. `./wp-install.sh web /var/www/site.com` <br>
  For Database Server configuration: <br>
  Usage, `./wp-install.sh webIP databaseName databaseUser` <br>
  Ex. `./wp-install.sh 10.10.0.1 site_com site_user` <br>
  For servers where the site and database files are on the same server pass localhost or 127.0.0.1 for the web server IP. <br>
* **wp-update.sh**, a BASH script for updating WordPress sites. Takes a site webroot as an argument. <br>
  Usage, `./wp-update.sh /path/to/webroot`<br>
  Also has a function for updating all sites at `/var/www`. <br>
  Minimal checks, should only be run if guided update function runs successfully. <br>
  Usage. `./wp-update.sh auto` <br>
