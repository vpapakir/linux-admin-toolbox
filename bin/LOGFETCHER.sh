#!/bin/bash

rsync -chavzP --stats -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" "argyros@ocean.space.noa.gr:/var/log/apache2/error.log" "/home/ubuntu/LOGREPO/ocean"
rsync -chavzP --stats -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" "argyros@ocean.space.noa.gr:/var/log/apache2/access.log" "/home/ubuntu/LOGREPO/ocean"
rsync -chavzP --stats -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" "argyros@ocean.space.noa.gr:/var/log/syslog" "/home/ubuntu/LOGREPO/ocean"
