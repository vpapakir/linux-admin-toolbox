#!/bin/bash

RECIPIENT="vpapakir@noa.gr"
DATAFILE="/home/ubuntu/networkdata.csv"
SSHLOG="/var/log/SSH.log"

logEvent() {
        #echo "["$(date -R)"] [$IPADDR] [$HOSTNAME] [$EVENTCATEGORY]: [$EVENTMESSAGE]"
        echo "["$(date -R)"] [$1] [$2] [$3]: [$4]"
}

mailReport() {
         #echo -e "Subject: HEALTH REPORT:[ "$SERVER2CHECK "("$HOSTNAME") - "$(date -R)"]\r\n\r\n$REPORT" | msmtp -a default $RECEIVER
         echo -e "Subject: HEALTH REPORT:[ "$1 "("$2") - "$(date -R)"]\r\n\r\n$3" | msmtp -a default $4
}

cat $DATAFILE | while read line
do
        SERVER2SSH=$(echo $line | cut -d'"' -f2)
        TOSSH=$(echo $line | cut -d'"' -f8)
	echo $TOSSH
        if [ $TOSSH = "SSH" ]; then
		SSHRETURN=$(nmap -p22 -Pn $SERVER2SSH | grep "22/tcp" | awk {'print $2'})
                if [ $SSHRETURN = "closed" ]; then
                	RESULT="["$(date -R)"] [ "$SERVER2SSH" ] [ "$(nslookup $SERVER2SSH | grep name | awk {'print $4'})" ] [ "$SSHRETURN" ] SSH/SFTP Service is DOWN or BLOCKING our probes. Please Inspect..."
		elif [ $SSHRETURN = "filtered" ]; then
                        RESULT="["$(date -R)"] [ "$SERVER2SSH" ] [ "$(nslookup $SERVER2SSH | grep name | awk {'print $4'})" ] [ "$SSHRETURN" ] SSH/SFTP Service is DOWN or BLOCKING our probes. Please Inspect..."
                elif [ $SSHRETURN = "open" ]; then
                        RESULT="["$(date -R)"] [ "$SERVER2SSH" ] [ "$(nslookup $SERVER2SSH | grep name | awk {'print $4'})" ] [ "$SSHRETURN" ] SSH/SFTP Service is UP!"
		else
			RESULT="["$(date -R)"] [ "$SERVER2SSH" ] [ "$(nslookup $SERVER2SSH| grep name | awk {'print $4'})" ] [ "$SSHRETURN" ] SSH/SFTP Service is DOWN! Please inspect..."
                fi
                sudo echo $RESULT >> $SSHLOG
        fi
done

echo -e "Subject: HEALTH REPORT:[ SSH - "$(date -R)"]\r\n\r\n$(cat $SSHLOG)" | msmtp -a default $RECIPIENT

echo "========================================================================" >> $SSHLOG
