#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}/../config/config.sh"
source "${DIR}/../functions/functions.sh"

cat $DATAFILE | while read line
do
        SERVER2PING=$(echo $line | cut -d'"' -f2)
	TOPING=$(echo $line | cut -d'"' -f4)
	if [ $TOPING = "PING" ]; then
		PINGRETURN=$(ping -D -c $COUNT -v $SERVER2PING | grep transmitted | awk {'print $1$4'})
		if [ $PINGRETURN -eq $COUNT$COUNT ]; then
			RESULT="["$(date -R)"] [ "$SERVER2PING" ] [ "$(nslookup $SERVER2PING | grep name | awk {'print $4'})" ] [ "$PINGRETURN" ] Server is UP!" 
		else
			RESULT="["$(date -R)"] [ "$SERVER2PING" ] [ "$(nslookup $SERVER2PING | grep name | awk {'print $4'})" ] [ "$PINGRETURN" ] Server does not respond to PING. That means that server is either down or blocking our pings. Please inspect..."
		fi
		PINGRETURN=""
		sudo echo $RESULT >> $PINGLOG
	fi
done

echo -e "Subject: HEALTH REPORT:[ PING - "$(date -R)"]\r\n\r\n$(cat $PINGLOG)" | msmtp -a default $RECIPIENT
