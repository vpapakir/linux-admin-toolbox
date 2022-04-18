#!/bin/bash

logEvent() {
        #echo "["$(date -R)"] [$IPADDR] [$HOSTNAME] [$EVENTCATEGORY]: [$EVENTMESSAGE]"
        echo "["$(date -R)"] [$1] [$2] [$3]: [$4]"
}

send_mail_report() {
	if ! command -v msmtp &> /dev/null
	then
		exit 97
	fi
	echo -e "Subject: HEALTH REPORT:[ "$1 "("$2") - "$(date -R)"]\r\n\r\n$3" | msmtp -a default $4
}
