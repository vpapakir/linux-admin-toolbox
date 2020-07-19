#!/bin/bash

cat /var/log/fail2ban.log* | grep " Ban " | awk '{print $8}' | sort -n -r | uniq
