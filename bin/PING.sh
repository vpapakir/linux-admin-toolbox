#!/bin/bash

echo "[INFO] Calculating base directory..."
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "[INFO] Base directory is ${DIR}"

if [[ -z "${DIR}/../config/config.sh" ]]; then
	source "${DIR}/../config/config.sh"
	CONFIG_FILE_LOADED=$?
	if [[ $CONFIG_FILE_LOADED -ne 0 ]]; then
		echo "[WARNING] Config file was not found or not loaded correctly. Reverting to sane defaults..."
		DATAFILE="tests/datafile.txt"
	else
		echo "[INFO] Loaded config file successfully..."
	fi
else
	echo "[WARNING] Config file was not found or not loaded correctly. Reverting to sane defaults..."
	PINGLOG="/tmp/ping.txt"
	DATAFILE="tests/ping.txt"
fi

source "${DIR}/../functions/functions.sh"
FUNCTION_FILE_LOADED=$?
if [[ $FUNCTION_FILE_LOADED -ne 0 ]]; then
        echo "[WARNING] Config file was not found or not loaded correctly. Exiting..."
        exit 99
else
	echo "[INFO] Loaded function file successfully"
fi

rm -v "/tmp/ping.txt"
cat $DATAFILE | while read -r line
do
        SERVER2PING=$(echo $line | cut -d "," -f2)
	PINGRETURN=$(ping ${SERVER2PING} -c 3 -q 2>&1 | grep loss | awk '{print $7}' | cut -d "%" -f1)
	if [[ "${PINGRETURN}" == "0.0" ]]; then
		RESULT="["$(date -R)"] [ "$SERVER2PING" ] [ "$(nslookup $SERVER2PING | grep name | awk {'print $4'})" ] [ "$PINGRETURN" ] Server is UP!" 
	else
		RESULT="["$(date -R)"] [ "$SERVER2PING" ] [ "$(nslookup $SERVER2PING | grep name | awk {'print $4'})" ] [ "$PINGRETURN" ] Server does not respond to PING. That means that server is either down or blocking our pings. Please inspect..."
	fi
	PINGRETURN=""
	echo $RESULT >> $PINGLOG
done

if [[ -f $PINGLOG ]]; then
	echo "[INFO] Sending out report in email..."
	HAS_SENT=$(send_mail_report "PING" "${HOSTNAME}" "${PINGLOG}" "${RECIPIENT}")
	if [[ "${HAS_SENT}" == "97" ]]; then
		echo "[ERROR] Mail report could not be sent as the msmtp mail client is not available"
		exit 97
	fi
else
	echo "[INFO] No ping data to be sent out. Exiting..."
	exit 98
fi

rm -v "${PINGLOG}"
