#!/bin/bash

DAYSTOMONITOR=5
COUNTER=0
USERNAME=""
SERVER=""
COMMAND=""
RECIPIENT="vpapakir@noa.gr"
PROCESSLOG="/var/log/PROCESSLOG.log"

echo "=======================================================================================================" >> $PROCESSLOG

USERNAME="vpapakir"
SERVER="83.212.125.176"
echo "["$(date -R)"] [$SERVER (LDA SERVER 1)]" >> $PROCESSLOG
ssh $USERNAME@$SERVER "ps auxww | grep python | grep -v grep" >> $PROCESSLOG

echo " " >> $PROCESSLOG

USERNAME="mirroradmin"
SERVER="83.212.169.91"
echo "[ $(date -R) ] [ $SERVER ] [ $(nslookup $SERVER | grep name | awk {'print $4'}) ]" >> $PROCESSLOG
ssh $USERNAME@$SERVER "ps auxww | grep python | grep -v grep" | awk '{for(i=9;i<NF;i++)printf "%s",$i OFS; if (NF) printf "%s",$NF; printf ORS}' >> $PROCESSLOG

echo -e "Subject: HEALTH REPORT:[ RUNNING PROCESSES - "$(date -R)"]\r\n\r\n$(cat $PROCESSLOG)" | msmtp -a default $RECIPIENT

