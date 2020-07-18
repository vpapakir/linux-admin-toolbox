#!/bin/bash

RECIPIENT="vpapakir@noa.gr"
DATAFILE="/home/ubuntu/networkdata.csv"
DISKLOG="/var/log/DISK.log"
MEMLOG="/var/log/MEMORY.log"
MEMCOMMAND='free -m'

logEvent() {
        #echo "["$(date -R)"] [$IPADDR] [$HOSTNAME] [$EVENTCATEGORY]: [$EVENTMESSAGE]"
        echo "["$(date -R)"] [$1] [$2] [$3]: [$4]"
}

mailReport() {
         #echo -e "Subject: HEALTH REPORT:[ "$SERVER2CHECK "("$HOSTNAME") - "$(date -R)"]\r\n\r\n$REPORT" | msmtp -a default $RECEIVER
         echo -e "Subject: HEALTH REPORT:[ "$1 "("$2") - "$(date -R)"]\r\n\r\n$3" | msmtp -a default $4
}

do_ssh() {
    ssh -n $1"@"$2 "$3"
    echo -e
}

echo "====================================" >> $DISKLOG
cat $DATAFILE | while read line
do
        SERVER2DISK=$(echo $line | cut -d'"' -f2)
        TODISK=$(echo $line | cut -d'"' -f10)
	USERNAME=$(echo $line | cut -d'"' -f12)
	PARTITION=$(echo $line | cut -d'"' -f18)
	DISKCOMMAND="df -hPT | grep -vE 'Filesystem|tmpfs|cdrom|none|udev' | awk '{ print $5 \" \" $1 }'"
        if [ $TODISK = "DISK" ]; then
            	RESULT="["$(date -R)"] [ "$SERVER2DISK" ] [ "$(nslookup $SERVER2DISK | grep name | awk {'print $4'})" ] "
                sudo echo $RESULT >> $DISKLOG
		do_ssh $USERNAME $SERVER2DISK $DISKCOMMAND | grep -vE 'tmpfs|cdrom|none|udev' >> $DISKLOG

            	RESULT="["$(date -R)"] [ "$SERVER2DISK" ] [ "$(nslookup $SERVER2DISK | grep name | awk {'print $4'})" ] "
                sudo echo $RESULT >> $MEMLOG
		do_ssh $USERNAME $SERVER2DISK $MEMCOMMAND >> $MEMLOG
        fi
done
echo "====================================" >> $DISKLOG

echo -e "Subject: HEALTH REPORT:[ MEMORY USAGE - "$(date -R)"]\r\n\r\n$(cat $MEMLOG)" | msmtp -a default $RECIPIENT
echo -e "Subject: HEALTH REPORT:[ DISK USAGE - "$(date -R)"]\r\n\r\n$(cat $DISKLOG)" | msmtp -a default $RECIPIENT
