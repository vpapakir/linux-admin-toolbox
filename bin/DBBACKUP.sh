#!/bin/bash

INPUT="DBDATA.csv"
RECIPIENT="vpapakir@noa.gr"
DBBACKUPLOG="/var/log/DBBACKUP.log"
DATE=$(date +%Y%m%d)
DESTUNAME="vpapakir"
DESTHOST="83.212.125.176"

cat $INPUT | while read line
do
	ID=$(echo $line | cut -d'"' -f2)
	ENABLED=$(echo $line | cut -d'"' -f4) 
	HOST=$(echo $line | cut -d'"' -f6)
	DBTYPE=$(echo $line | cut -d'"' -f8) 
	USERNAME=$(echo $line | cut -d'"' -f10) 
	PASSWORD=$(echo $line | cut -d'"' -f12)
	DBNAME=$(echo $line | cut -d'"' -f14)

	if [ $ENABLED == "1" ]; then
		if [ ! $HOST ]; then
	                HOST="localhost"
	        fi;
	       	if [ ! $USERNAME ]; then
	               	USERNAME="postgres"
		fi;
	        if [ ! $DBTYPE ]; then
	       	        DBTYPE="POSTGRES"
	        fi;
		if [ $DBTYPE == "MYSQL" ]; then
			echo "["$(date -R)"] [$HOST] [$DBNAME] Backup started..." >> $DBBACKUPLOG
			mysql -v -h $HOST -u $USERNAME -p'$PASSWORD' $DBNAME
			if [ $? -eq 0  ]; then
				mysqldump -v -h $HOST -u $USERNAME -p'$PASSWORD' $DBNAME | gzip > $DBNAME"_"$DATE.sql.gz
				scp $DBNAME"_"$DATE.sql.gz "$DESTUNAME"@"$DESTHOST":"/mnt/data/BACKUP/DB/OCEAN"
				if [ $? -eq 0  ]; then
					echo "["$(date -R)"] [$HOST] [$DBNAME] Backup finished and transfered..." >> $DBBACKUPLOG
					rm $DBNAME"_"$DATE.sql.gz
				else
					echo "["$(date -R)"] [$HOST] [$DBNAME] Backup taken successfully but could not be transfered to the backup storage ($?). PLEASE INSPECT!!!" >> $DBBACKUPLOG
				fi
			else
				echo "["$(date -R)"] [$HOST] [$DBNAME] Could not connect to the database specified ($?). PLEASE INSPECT!!!" >> $DBBACKUPLOG
			fi
		else
#		if [ $DBTYPE == "POSTGRES" ]; then
			echo "["$(date -R)"] [$HOST] [$DBNAME] Backup started..." >> $DBBACKUPLOG
			psql -h $HOST -U $USERNAME -c "\q"
                        if [ $? -eq 0  ]; then
				pg_dump -h $HOST -U $USERNAME $DBNAME | gzip > $DBNAME"_"$DATE.sql.gz
                                scp $DBNAME"_"$DATE.sql.gz "$DESTUNAME"@"$DESTHOST":"/mnt/data/BACKUP/DB/COLGRDBSRV"
                                if [ $? -eq 0  ]; then
                                        echo "["$(date -R)"] [$HOST] [$DBNAME] Backup finished and transfered..." >> $DBBACKUPLOG
					rm $DBNAME"_"$DATE.sql.gz
                                else
                                        echo "["$(date -R)"] [$HOST] [$DBNAME] Backup taken successfully but could not be transfered to the backup storage ($?). PLEASE INSPECT!!!" >> $DBBACKUPLOG
                                fi
                        else
                                echo "["$(date -R)"] [$HOST] [$DBNAME] Could not connect to the database specified ($?). PLEASE INSPECT!!!" >> $DBBACKUPLOG
                       fi
		fi;
	else
		echo "["$(date -R)"] [$HOST] [$DBNAME] Host is disabled. No backup will be taken..." >> $DBBACKUPLOG
	fi;
done

echo -e "Subject: BACKUP REPORT:[ DATABASES - "$(date -R)"]\r\n\r\n$(cat $DBBACKUPLOG)" | msmtp -a default $RECIPIENT
