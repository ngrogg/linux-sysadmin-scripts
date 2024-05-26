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
* **smtpTest.pl**, A perl script for testing SMTP connections on a server. Two sections to fill out.
  First is the SMTP server section, which includes the host, port, user, password and addressee.
  Second section is to fill in the email From, To, Subject and Body. Afterwards run the script. <br>
* **passgen.sh**, a BASH script for generating passwords. Probably not industry shattering, but good enough for most uses.<br>
* **structureCheck.py**, A Python script for cron folders like `/etc/cron.daily` used to launch the structureCheck.sh script below. <br>
  Usage, just run the script. <br>
* **structureCheck.sh**, A BASH script for checking for disk corruption on a server.
  Takes a sender email and recipient as arugments. <br>
  Usage, `./structureCheck.sh check SENDER@email.com RECIPIENT@email.com` <br>
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
