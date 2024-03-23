<?php

# A simple php script to test that a user is able to connect to a database
# Run on Welsh server 
# Fill in values as needed.

error_reporting(0);

$dbname  = 'DATABASE';
$dbuser  = 'USER';
$dbpass  = 'PASSWORD';
$dbhost  = 'HOSTNAME';
$connect = mysqli_connect($dbhost, $dbuser, $dbpass, $dbname);

if(!$connect){
        die("Connection failed: "  . mysqli_connect_error() . "\n");
}
echo "Connected Successfully\n";

?>
