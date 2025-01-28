<?php
# PHP script to output php-fpm info
# https://www.php.net/manual/en/function.fpm-get-status.php
# Goes in docroot, access via curl
# curl https://domain.com/fpmStatus.php

print_r(fpm_get_status());
?>
