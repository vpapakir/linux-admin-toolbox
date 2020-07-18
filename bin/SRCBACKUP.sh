#!/bin/bash

RECIPIENT="vpapakir@noa.gr"
DATAFILE="/home/ubuntu/bkpdata.csv"
SRCBACKUPLOG="/var/log/SRCBACKUP.log"
DATE=$(date +%Y%m%d)

DESTUNAME="vpapakir"
DESTHOST="83.212.125.176"
DESTPATH="/mnt/data/BACKUP/SRC/"

echo "==================================================" >> $SRCBACKUPLOG
cat $DATAFILE | while read line
do
        SERVER2BACKUP=$(echo $line | cut -d'"' -f2)
        DIR2BACKUP=$(echo $line | cut -d'"' -f4)
        OBJ2BACKUP=$(echo $line | cut -d'"' -f6)
	USERNAME=$(echo $line | cut -d'"' -f8)
	BACKUPDESC=$(echo $line | cut -d'"' -f10)
	echo $SERVER2BACKUP":"$USERNAME":"$DIR2BACKUP":"$BACKUPDESC
	scp -rCp $USERNAME"@"$SERVER2BACKUP":"$DIR2BACKUP "/home/ubuntu/"
	if [ $? -eq 0  ]; then
		tar -zcvf $BACKUPDESC"_"$DATE".tar.gz" $OBJ2BACKUP
		if [ $? -eq 0  ]; then
			scp -rCp  $BACKUPDESC"_"$DATE".tar.gz" $DESTUNAME"@"$DESTHOST":"$DESTPATH
			if [ $? -eq 0  ]; then
			        RESULT="["$(date -R)"] [ "$SERVER2BACKUP" ] [ "$(nslookup $SERVER2BACKUP | grep name | awk {'print $4'})" ] [ $? ] [ $BACKUPDESC  ] [ $DESTHOST:$DESTPATH  ] Backup successfully taken and stored..."
				rm $BACKUPDESC"_"$DATE".tar.gz"
				rm -R "/home/ubuntu/"$OBJ2BACKUP
				echo $RESULT >> $SRCBACKUPLOG
			else
			        RESULT="["$(date -R)"] [ "$SERVER2BACKUP" ] [ "$(nslookup $SERVER2BACKUP | grep name | awk {'print $4'})" ] [ $? ] [ $BACKUPDESC  ] Error while storing backup to remote. PLEASE INSPECT!!!"
				echo $RESULT >> $SRCBACKUPLOG
			fi
		else
		        RESULT="["$(date -R)"] [ "$SERVER2BACKUP" ] [ "$(nslookup $SERVER2BACKUP | grep name | awk {'print $4'})" ] [ $? ] [ $BACKUPDESC_$DATE.tar.gz  ] Error while compressing backup. PLEASE INSPECT!!!"
			echo $RESULT >> $SRCBACKUPLOG
		fi
	else
	        RESULT="["$(date -R)"] [ "$SERVER2BACKUP" ] [ "$(nslookup $SERVER2BACKUP | grep name | awk {'print $4'})" ] [ $? ] [ $BACKUPDESC ] Error while fetching code from remote. PLEASE INSPECT!!!"
		echo $RESULT >> $SRCBACKUPLOG
	fi
done
echo "==================================================" >> $SRCBACKUPLOG

echo -e "Subject: BACKUP REPORT:[ SOURCE CODE BACKUP - "$(date -R)"]\r\n\r\n$(cat $SRCBACKUPLOG)" | msmtp -a default $RECIPIENT
