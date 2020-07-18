#!/bin/bash

mailReport() {
         #echo -e "Subject: HEALTH REPORT:[ "$SERVER2CHECK "("$HOSTNAME") - "$(date -R)"]\r\n\r\n$REPORT" | msmtp -a default $RECEIVER
         echo -e "Subject: HEALTH REPORT:[ "$1 "("$2") - "$(date -R)"]\r\n\r\n$3" | msmtp -a default $4
}

echo "" > /var/log/CUSTOMLOG.log

DAYSTOMONITOR=5
COUNTER=0
USERNAME=""
SERVER=""
COMMAND=""
RECIPIENT="vpapakir@noa.gr"
CUSTOMLOG="/var/log/CUSTOMLOG.log"

echo "CUSTOM CHECK: DAILY FILES IN X-BAND PROCESSING SERVER" >> $CUSTOMLOG
while [ $COUNTER -lt $DAYSTOMONITOR ]; do
	USERNAME="vxeos"
	SERVER="195.251.202.106"
	DATE=$(date +%Y%m%d --date="$COUNTER days ago")
	EOSRETURN=$(ssh $USERNAME@$SERVER ls -l /data/Images/EOS/)
	EOSCOUNT=$(echo "$EOSRETURN" | awk {'print $9'} | grep "$DATE" | wc -l)
	if [ $EOSCOUNT -gt 0  ]; then
		echo "[$DATE] [$SERVER] [EOS]: OK" >> $CUSTOMLOG
	else
		echo "[$DATE] [$SERVER] [EOS]: NO DATA! PLEASE INSPECT!"  >> $CUSTOMLOG
	fi
	FY3RETURN=$(ssh $USERNAME@$SERVER ls -l /data/Images/FY3/)
	FY3COUNT=$(echo "$FY3RETURN" | awk {'print $9'} | grep "$DATE" | wc -l)
        if [ $FY3COUNT -gt 0  ]; then
                echo "[$DATE] [$SERVER] [FY3]: OK" >> $CUSTOMLOG
        else
                echo "[$DATE] [$SERVER] [FY3]: NO DATA! PLEASE INSPECT!" >> $CUSTOMLOG
        fi
	NPPRETURN=$(ssh $USERNAME@$SERVER ls -l /data/Images/NPP/)
	NPPCOUNT=$(echo "$NPPRETURN" | awk {'print $9'} | grep "$DATE" | wc -l)
        if [ $NPPCOUNT -gt 0  ]; then
                echo "[$DATE] [$SERVER] [NPP]: OK" >> $CUSTOMLOG
        else
                echo "[$DATE] [$SERVER] [NPP]: NO DATA! PLEASE INSPECT!" >> $CUSTOMLOG
        fi
	let COUNTER=COUNTER+1
done
echo "=============================================" >> $CUSTOMLOG

echo "CUSTOM CHECK: DAILY FILES IN L-BAND ACQUISITION & PROCESSING SERVER" >> $CUSTOMLOG
COUNTER=0
while [ $COUNTER -lt $DAYSTOMONITOR ]; do
        USERNAME="vxeos"
        SERVER="195.251.202.110"
        DATE=$(date +%Y%m%d --date="$COUNTER days ago")
        EPSRETURN=$(ssh $USERNAME@$SERVER ls -l /data/Images/EPS/)
        EPSCOUNT=$(echo "$EPSRETURN" | awk {'print $9'} | grep "$DATE" | wc -l)
        if [ $EPSCOUNT -gt 0  ]; then
                echo "[$DATE] [$SERVER] [EPS]: OK" >> $CUSTOMLOG
        else
                echo "[$DATE] [$SERVER] [EPS]: NO DATA! PLEASE INSPECT!"  >> $CUSTOMLOG
        fi
        NOAARETURN=$(ssh $USERNAME@$SERVER ls -l /data/Images/NOAA/)
        NOAACOUNT=$(echo "$NOAARETURN" | awk {'print $9'} | grep "$DATE" | wc -l)
        if [ $NOAACOUNT -gt 0  ]; then
                echo "[$DATE] [$SERVER] [NOAA]: OK" >> $CUSTOMLOG
        else
                echo "[$DATE] [$SERVER] [NOAA]: NO DATA! PLEASE INSPECT!" >> $CUSTOMLOG
        fi
        let COUNTER=COUNTER+1
done
echo "=============================================" >> $CUSTOMLOG

DATE=$(date +%Y-%m-%d)
SERVER="83.212.125.176"
USERNAME="root"
PATH2EXAMINE="/home/stavros/WRF_ARW/ANALYSIS/"
echo "CUSTOM CHECK: DAILY WRF FILES IN LDA SERVER 1" >> $CUSTOMLOG
WRFRETURN=$(ssh $USERNAME@$SERVER ls -l $PATH2EXAMINE)
WRFCOUNT=$(echo "$WRFRETURN" | awk {'print $9'} | grep "$DATE" | wc -l)
if [ $WRFCOUNT -gt 0  ]; then
        echo "[$DATE] [$SERVER] Found "$WRFCOUNT" daily WRF files. Model executes fine." >> $CUSTOMLOG
else
        echo "[$DATE] [$SERVER] No WRF files found for today! PLEASE INSPECT!!!" >> $CUSTOMLOG
fi
echo "=============================================" >> $CUSTOMLOG

echo -e "Subject: HEALTH REPORT:[ FILE STRUCTURE - "$(date -R)"]\r\n\r\n$(cat $CUSTOMLOG)" | msmtp -a default $RECIPIENT
