#!/bin/bash

SITE2CHECK=$1
TIMEOUT=$2
REPORT=""
REPORT_ALT=""
TOKS=( $(wget --timeout=$TIMEOUT $SITE2CHECK 2>&1 | grep HTTP | awk -F' ' '{print $6}') )

if [ ${#TOKS[@]} -eq 0 ]; then
	REPORT=$REPORT"No response fron "$SITE2CHECK",probably network error. Please inspact further..."
else
	for i in "${TOKS[@]}"
	do
		:
		REPORT_ALT=$i
		if [ $i -eq 200 ]; then
                	REPORT=$REPORT"\nRequest succeeded (200). Site is up!"
			rm -Rf /home/ubuntu/index.html*
                fi
		if [ $i -eq 301 ]; then
			REPORT=$REPORT"\nRequest redirected (301). So far, so good..." 
		fi
		if [ $i -eq 302 ]; then
                        REPORT=$REPORT"\nRequest redirected (302). So far, so good..."
                fi
	done
fi

echo -e "Subject: HEALTH REPORT:[ "$SITE2CHECK"  - "$(date -R)"]\r\n\r\n"$REPORT"\r\n\r\nOTHER INFO:"$REPORT_ALT | msmtp -a default vpapakir@noa.gr
