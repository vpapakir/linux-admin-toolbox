#!/bin/sh

#df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
#do
  #echo $output
#  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
#  partition=$(echo $output | awk '{ print $2 }' )
#  if [ $usep -ge 90 ]; then
#    echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)"
#  else
#    echo "Adequate space left on \"$partition ($usep%)\" on $(hostname) as on $(date)"
#  fi
#done


DATE=$(date +%Y-%m-%d)
SERVER="83.212.125.176"
USERNAME="root"
PATH2EXAMINE="/home/stavros/WRF_ARW/ANALYSIS/"
echo "CUSTOM CHECK: DAILY WRF FILES IN LDA SERVER 1" >> $CUSTOMLOG
WRFRETURN=$(ssh $USERNAME@$SERVER ls -l $PATH2EXAMINE)
WRFCOUNT=$(echo "$WRFRETURN" | awk {'print $9'} | grep "$DATE" | wc -l)
if [ $WRFCOUNT -gt 0  ]; then
	echo "[$DATE] [$SERVER] Found "$WRFCOUNT" daily WRF files. Model executes fine." >> $CUSTOMLOG
else
	echo "[$DATE] [$SERVER] No WRF files found for today! PLEASE INSPECT!!!" >> $CUSTOMLOG
fi
echo "=============================================" >> $CUSTOMLOG
