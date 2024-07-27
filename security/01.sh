#!/bin/bash

cd /root/php-malware-scanner

git config pull.rebase false

git pull

./scan -E \
       --base64 \
       -d /var/www/ \
       -s \
       -a \
       -x \
       -b \
       -n \
       -k \
       -c \
       -t

find ${WEB_PATH} -type f -name '*.php' ! -name "scss.inc.php" | xargs grep -l " *@include *" | xargs -I {} mv -v {} /root/dev/attacks/
find ${WEB_PATH} -type f -name "*.*.ico*" ! -name "Litespeed*" | xargs -I {} mv -v {} /root/dev/attacks/

index_php_size=$(stat ${WEB_PATH}index.php | grep Size | awk '{print $2}')
wp_settings_php_size=$(stat ${WEB_PATH}wp-settings.php | grep Size | awk '{print $2}')
wp_config_php_size=$(stat ${WEB_PATH}wp-config.php | grep Size | awk '{print $2}')

if [[ ${index_php_size} -ne 405 ]]; then
	rm -v ${WEB_PATH}index.php
    cp -v /root/index.php.healthy ${WEB_PATH}index.php
else
	echo "[INFO] index.php is ok"
fi

if [[ ${wp_settings_php_size} -ne 22297 ]]; then
	rm -v ${WEB_PATH}wp-settings.php
    cp -v /root/wp-settings.php.healthy ${WEB_PATH}wp-settings.php
else
	echo "[INFO] wp-settings.php is ok"
fi

if [[ ${wp_config_php_size} -ne 3593 ]]; then
	rm -v ${WEB_PATH}wp-config.php
    cp -v /root/wp-config.php.healthy ${WEB_PATH}wp-config.php
else
	echo "[INFO] wp-config.php is ok"
fi 
