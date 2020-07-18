#!/bin/bash

RECIPIENT="vpapakir@noa.gr"
DATAFILE="/home/ubuntu/networkdata.csv"
VNCLOG="/var/log/VNC.log"

logEvent() {
        #echo "["$(date -R)"] [$IPADDR] [$HOSTNAME] [$EVENTCATEGORY]: [$EVENTMESSAGE]"
        echo "["$(date -R)"] [$1] [$2] [$3]: [$4]"
}

mailReport() {
         #echo -e "Subject: HEALTH REPORT:[ "$SERVER2CHECK "("$HOSTNAME") - "$(date -R)"]\r\n\r\n$REPORT" | msmtp -a default $RECEIVER
         echo -e "Subject: HEALTH REPORT:[ "$1 "("$2") - "$(date -R)"]\r\n\r\n$3" | msmtp -a default $4
}

echo "==================================================" >> $VNCLOG
cat $DATAFILE | while read line
do
        SERVER2VNC=$(echo $line | cut -d'"' -f2)
        TOVNC=$(echo $line | cut -d'"' -f14)
	VNCPORT=$(echo $line | cut -d'"' -f16)
        if [ $TOVNC = "VNC" ]; then
		#echo $SERVER2VNC":"$VNCPORT" => "$TOVNC
		VNCRETURN=$(nmap -p$VNCPORT -Pn $SERVER2VNC | grep "$VNCPORT/tcp" | awk {'print $2'})
		echo $VNCRETURN
                if [ $VNCRETURN = "closed" ]; then
                	RESULT="["$(date -R)"] [ "$SERVER2VNC" ] [ "$(nslookup $SERVER2VNC | grep name | awk {'print $4'})" ] [ "$VNCRETURN" ] VNC Service is DOWN or BLOCKING our probes. Please Inspect..."
		elif [ $VNCRETURN = "filtered" ]; then
                        RESULT="["$(date -R)"] [ "$SERVER2VNC" ] [ "$(nslookup $SERVER2VNC | grep name | awk {'print $4'})" ] [ "$VNCRETURN" ] VNC Service is DOWN or BLOCKING our probes. Please Inspect..."
                elif [ $VNCRETURN = "open" ]; then
                        RESULT="["$(date -R)"] [ "$SERVER2VNC" ] [ "$(nslookup $SERVER2VNC | grep name | awk {'print $4'})" ] [ "$VNCRETURN" ] VNC Service is UP!"
		else
			RESULT="["$(date -R)"] [ "$SERVER2VNC" ] [ "$(nslookup $SERVER2VNC | grep name | awk {'print $4'})" ] [ "$VNCRETURN" ] VNCService is DOWN! Please inspect..."
                fi
                sudo echo $RESULT >> $VNCLOG
        fi
done
echo "==================================================" >> $VNCLOG

echo -e "Subject: HEALTH REPORT:[ VNC - "$(date -R)"]\r\n\r\n$(cat $VNCLOG)" | msmtp -a default $RECIPIENT
