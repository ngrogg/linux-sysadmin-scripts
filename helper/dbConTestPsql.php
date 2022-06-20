<?php
# PHP Script to test connections to Postgres databases

# CentOS 7 required the following additions to work:
# yum install php74-php-pgsql.x86_64 

# Added the following to php.ini
# extension=/opt/remi/php74/root/usr/lib64/php/modules/pgsql.so
# Restart apache (graceful works)
# Restart php-fpm (if installed)

# Replace host with Database server IP
# Replace password with corect password

if (!$connection = pg_connect ("host=localhost dbname=postgres user=postgres password=root")) {
    $error = error_get_last();
    echo "Connection failed. Error was: ". $error['message']. "\n";
} else {
    echo "Connection successful.\n";
}

?>
