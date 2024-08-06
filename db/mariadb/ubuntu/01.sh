#!/bin/bash

## Software maintenance
apt-get -y install vim htop nmap nload mariadb-server iotop mariadb-client samba cifs-utils
apt-get upgrade
#######################

## Mount external disks
mkdir -pv /mnt/backup
IS_MOUNTED=$(cat /etc/fstab | grep ${CIFS_USERNAME} | wc -l)
if [[ ${IS_MOUNTED} -lt 1 ]]; then
	echo "//136.243.27.235/backup/${HOME_SITE} /mnt/backup cifs username=${CIFS_USERNAME},password=${CIFS_PASSWORD},uid=www-data,gid=www-data,rw,cache=loose,file_mode=0600,dir_mode=0777,vers=3.0 0 0" >> /etc/fstab
else
	echo "[INFO] backup is already mounted"
fi
mount -a -v
df -h
#######################

## Backup database
tstamp=$(date +'%s')
mysqldump -h localhost -u root -p${MYSQL_PASSWORD} dn1 > /mnt/backup/dn1.${tstamp}.sql
#######################
