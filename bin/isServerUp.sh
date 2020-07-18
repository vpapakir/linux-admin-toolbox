#!/bin/bash

CHECKTOOL=$1 # PING, NMAP, WGET, NSLOOKUP, USAGE
SERVICE2CHECK=""
SERVER2CHECK=""
USERNAME=""
DATETIMEOFCHECK=$(date -R)
RECEIVER="vpapakir@noa.gr"
REPORT=""

is_alive_ping()
{
  ping -c 1 $1 > /dev/null
  [ $? -eq 0 ] && echo Node with IP: $i is up.
}

do_ssh() {
    ssh $USERNAME"@"$s "$@"
    echo -e
}

header() {
    echo "#==================={$@}==========================#"
}

if [ "$CHECKTOOL" == "NMAP" ]; then
	RES1=$(dpkg -s $CHECKTOOL | grep Status | awk -F' ' '{print $3}')
	if [ "$RES1" == "ok" ]; then
  		echo $CHECKTOOL" is installed. Proceed with health checking..."
	else
		# TODO: invoke tool installation according to distro
        	sudo apt-get install $CHECKTOOL
	fi
fi

if [ "$CHECKTOOL" == "NMAP" ]; then
	echo "HEALTH CHECK WITH NMAP"
	SERVER2CHECK=$2  # POSSIBLE VALUES: Any FQDN or IPv4 address
	SERVICE2CHECK=$3 # POSSIBLE VALUES: SSH, FTP, POSTGRES, MYSQL, HTTP, HTTPS, VNC
        HOSTNAME=$(nslookup $SERVER2CHECK | grep name |  awk -F' ' '{print $4}')
        REPORT=$REPORT"\r\n\r\n================== NMAP HEALTH CHECK ====================\r\n\r\n"
	if [ "$SERVICE2CHECK" == "SSH" ]; then
		TMP=$(nmap -Pn -p22 $SERVER2CHECK)
		REPORT=$REPORT"$TMP"
		STATE=$(echo "$TMP" | grep ssh | awk -F' ' '{print $2}')
		PROTOCOL=$(echo "$TMP" | grep ssh | awk -F' ' '{print $3}')
		if [ "$STATE" != "open" -o "$PROTOCOL" != "ssh" ]; then
			echo -e "Subject: HEALTH REPORT:[ "$SERVER2CHECK "("$HOSTNAME") - "$(date -R)"]\r\n\r\nSSH Service is DOWN! Please inspect..." | msmtp -a default $RECEIVER
		else
			echo -e "Subject: HEALTH REPORT:[ "$SERVER2CHECK "("$HOSTNAME") - "$(date -R)"]\r\n\r\nSSH Service is UP!" | msmtp -a default $RECEIVER
		fi
	fi
        if [ "$CHECKTOOL" == "FTP" ]; then
		echo "NOT IMPLEMENTED YET";
        fi
        if [ "$CHECKTOOL" == "POSTGRES" ]; then
		echo "NOT IMPLEMENTED YET";
        fi
        if [ "$CHECKTOOL" == "MYSQL" ]; then
		echo "NOT IMPLEMENTED YET";
        fi
        if [ "$CHECKTOOL" == "HTTP" ]; then
		echo "NOT IMPLEMENTED YET";
        fi
        if [ "$CHECKTOOL" == "HTTPS" ]; then
		echo "NOT IMPLEMENTED YET";
        fi
        if [ "$CHECKTOOL" == "VNC" ]; then
		echo "NOT IMPLEMENTED YET";
        fi
fi
if [ "$CHECKTOOL" == "PING" ]; then
        echo "HEALTH CHECK WITH PING"
	SERVER2CHECK=$2
	HOSTNAME=$(nslookup $SERVER2CHECK | grep name |  awk -F' ' '{print $4}')
	REPORT=$REPORT"\r\n\r\n================== PING HEALTH CHECK ====================\r\n\r\n"
	#is_alive_ping $SERVER2CHECK & disown
	ping -c 1 $SERVER2CHECK > /dev/null
        if [ $? -ne 0 ]; then
                REPORT=$REPORT"`date`: ping failed, $SERVER2CHECK host is probably down!"
                echo -e "Subject: HEALTH REPORT:[ "$SERVER2CHECK "("$HOSTNAME") - "$(date -R)"]\r\n\r\n$REPORT" | msmtp -a default $RECEIVER
	else
		REPORT=$REPORT"`date`: ping successful, $SERVER2CHECK alive!"
		echo -e "Subject: HEALTH REPORT:[ "$SERVER2CHECK "("$HOSTNAME") - "$(date -R)"]\r\n\r\n$REPORT" | msmtp -a default $RECEIVER
        fi
fi
if [ "$CHECKTOOL" == "WGET" ]; then
         echo "HEALTH CHECK WITH WGET"
fi
if [ "$CHECKTOOL" == "USAGE" ]; then
        echo "HEALTH CHECK WITH USAGE"
	SERVER2CHECK=$2
	USERNAME=$3
	HOSTNAME=$(nslookup $SERVER2CHECK | grep name |  awk -F' ' '{print $4}')
	remote_srv=( $SERVER2CHECK )
        n=${#remote_srv[@]} # number of ip's in array
        for (( i=0;i<$n;i++)); do
            echo -e
            echo "$(tput bold)$(tput setaf 2)* Connected Server: ${remote_srv[$i]}  @@ $(date) @@"
            echo "* Fetching info...$(tput sgr 0)"
            s=${remote_srv[$i]}

            REPORT=$(header "Resource Usage Report")
            TMP="ps auxw | grep python"
            REPORT="\r\n\r\n$REPORT\r\n\r\n"$(do_ssh $TMP)

            REPORT="\r\n\r\n$REPORT\r\n\r\n"$(header "Memory Usage")
            REPORT="\r\n\r\n$REPORT\r\n\r\n"$(do_ssh free -m)

            REPORT="\r\n\r\n$REPORT\r\n\r\n"$(header "Disk Usage")
            REPORT="\r\n\r\n$REPORT\r\n\r\n"$(do_ssh df -h)
        done
        echo -e "Subject: HEALTH REPORT:[ "$SERVER2CHECK "("$HOSTNAME") - "$(date -R)"]\r\n\r\n$REPORT" | msmtp -a default $RECEIVER
fi
if [ "$CHECKTOOL" == "NSLOOKUP" ]; then
         echo "HEALTH CHECK WITH NSLOOKUP"
	SERVER2CHECK=$2
        HOSTNAME=$(nslookup $SERVER2CHECK | grep name |  awk -F' ' '{print $4}')
        REPORT=$REPORT"\r\n\r\n================== PING HEALTH CHECK ====================\r\n\r\n"
fi
