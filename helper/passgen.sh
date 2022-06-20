#!/usr/bin/bash

pass=$(date +%s | sha256sum | base64 | head -c 30)
pass+=$(((RANDOM%1000+1)))
pass+="!"
echo $pass
