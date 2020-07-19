#!/bin/bash

cat /var/log/audit/audit.log* | grep -v "127.0.0.1" | grep -Po " hostname=[0-9\.]* | addr=[0-9\.]* " | cut -d "=" -f 2 | sort -n -r | uniq
