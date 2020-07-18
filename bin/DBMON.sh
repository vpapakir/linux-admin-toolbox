#!/bin/bash

RECIPIENT="vpapakir@noa.gr"
DATAFILE="/home/ubuntu/networkdata.csv"
DBMONLOG="/var/log/DBMON.log"

echo "==================================================" >> $DBMONLOG
cat $DATAFILE | while read line
do
        SERVER2DB=$(echo $line | cut -d'"' -f2)
        TODB=$(echo $line | cut -d'"' -f18)
	DBUSER=$(echo $line | cut -d'"' -f20)
	DBPORT=$(echo $line | cut -d'"' -f22)
        if [ $TODB = "NODB" ]; then
		RESULT="["$(date -R)"] [ "$SERVER2DB" ] [ "$(nslookup $SERVER2DB | grep name | awk {'print $4'})" ] [ "$DBRETURN" ] This server does not host any database..."
		sudo echo $RESULT >> $DBMONLOG
	else
		DBRETURN=$(nmap -p$DBPORT -Pn $SERVER2DB | grep "$DBPORT" | awk {'print $2'})
                if [ $DBRETURN = "closed" ]; then
                	RESULT="["$(date -R)"] [ "$SERVER2DB" ] [ "$(nslookup $SERVER2DB | grep name | awk {'print $4'})" ] [ "$DBRETURN" ] $TODB Service is DOWN or BLOCKING our probes. Please Inspect..."
		elif [ $DBRETURN = "filtered" ]; then
                        RESULT="["$(date -R)"] [ "$SERVER2DB" ] [ "$(nslookup $SERVER2DB | grep name | awk {'print $4'})" ] [ "$DBRETURN" ] $TODB Service is DOWN or BLOCKING our probes. Please Inspect..."
                elif [ $DBRETURN = "open" ]; then
                        RESULT="["$(date -R)"] [ "$SERVER2DB" ] [ "$(nslookup $SERVER2DB | grep name | awk {'print $4'})" ] [ "$DBRETURN" ] $TODB Service is UP!"
		else
			RESULT="["$(date -R)"] [ "$SERVER2DB" ] [ "$(nslookup $SERVER2DB | grep name | awk {'print $4'})" ] [ "$DBRETURN" ] $TODB Service is DOWN! Please inspect..."
                fi
                sudo echo $RESULT >> $DBMONLOG
        fi
done
echo "==================================================" >> $DBMONLOG

echo -e "Subject: HEALTH REPORT:[ DATABASE - "$(date -R)"]\r\n\r\n$(cat $DBMONLOG)" | msmtp -a default $RECIPIENT
