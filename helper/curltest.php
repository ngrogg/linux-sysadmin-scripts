<?php

// A PHP Script to test curl conenctions to a URL

// create a new cURL resource
$ch = curl_init();

// set URL and other appropriate options
curl_setopt($ch, CURLOPT_URL, "https://example.com");

// Specify port 
curl_setopt($ch, CURLOPT_PROXYPORT, "443");

// Curl headers? 0/1
curl_setopt($ch, CURLOPT_HEADER, 1);

// Verify SSL? 0/1
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);

// Manually specify an SSL to use
curl_setopt($ch, CURLOPT_CAINFO, "/path/to/cert.pem");

// Grab URL and pass it to the browser
curl_exec($ch);

// Output error message
if (curl_errno($ch))
{
print curl_error($ch);
}
// close cURL resource, and free up system resources
curl_close($ch);
?>

