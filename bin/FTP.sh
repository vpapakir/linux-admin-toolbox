#!/bin/bash

RECIPIENT="vpapakir@noa.gr"
DATAFILE="/home/ubuntu/networkdata.csv"
COUNT=2
FTPLOG="/var/log/FTP.log"

logEvent() {
        #echo "["$(date -R)"] [$IPADDR] [$HOSTNAME] [$EVENTCATEGORY]: [$EVENTMESSAGE]"
        echo "["$(date -R)"] [$1] [$2] [$3]: [$4]"
}

mailReport() {
         #echo -e "Subject: HEALTH REPORT:[ "$SERVER2CHECK "("$HOSTNAME") - "$(date -R)"]\r\n\r\n$REPORT" | msmtp -a default $RECEIVER
         echo -e "Subject: HEALTH REPORT:[ "$1 "("$2") - "$(date -R)"]\r\n\r\n$3" | msmtp -a default $4
}

echo "=======================================================================================" >> $FTPLOG

cat $DATAFILE | while read line
do
        SERVER2FTP=$(echo $line | cut -d'"' -f2)
        TOFTP=$(echo $line | cut -d'"' -f6)
        if [ $TOFTP = "FTP" ]; then
                #PINGRETURN=$(ping -D -c $COUNT -v $SERVER2PING | grep transmitted | awk {'print $1$4'})
		FTPRETURN=$(nmap -p21 -Pn $SERVER2FTP | grep "21/tcp" | awk {'print $2'})
                if [ $FTPRETURN = "closed" ]; then
                	RESULT="["$(date -R)"] [ "$SERVER2FTP" ] [ "$(nslookup $SERVER2FTP | grep name | awk {'print $4'})" ] [ "$FTPRETURN" ] FTP Service is DOWN or BLOCKING our probes. Please Inspect..."
		elif [ $FTPRETURN = "filtered" ]; then
                        RESULT="["$(date -R)"] [ "$SERVER2FTP" ] [ "$(nslookup $SERVER2FTP | grep name | awk {'print $4'})" ] [ "$FTPRETURN" ] FTP Service is DOWN or BLOCKING our probes. Please Inspect..."
                elif [ $FTPRETURN = "open" ]; then
                        RESULT="["$(date -R)"] [ "$SERVER2FTP" ] [ "$(nslookup $SERVER2FTP | grep name | awk {'print $4'})" ] [ "$FTPRETURN" ] FTP Service is UP!"
		else
			RESULT="["$(date -R)"] [ "$SERVER2FTP" ] [ "$(nslookup $SERVER2FTP | grep name | awk {'print $4'})" ] [ "$FTPRETURN" ] FTP Service is DOWN! Please inspect..."
                fi
                sudo echo $RESULT >> $FTPLOG
        fi
done

echo -e "Subject: HEALTH REPORT:[ FTP - "$(date -R)"]\r\n\r\n$(cat $FTPLOG)" | msmtp -a default $RECIPIENT
