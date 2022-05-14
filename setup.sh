#!/bin/bash

set -e

source base.sh

rm -f install.msg
preinstall wget curl gcc make 

source nginx/setup.sh
source mongod/setup.sh
source slapd/setup.sh
source php-fpm/setup.sh

SERVICE=""
SERVICE+=$(ist NGINX_RESTART && echo " nginx")
SERVICE+=$(ist MONGODB_RESTART && echo " mongod")
SERVICE+=$(ist LDAP_RESTART && echo " slapd")
SERVICE+=$(ist PHP_FPM_RESTART && echo " php-fpm")

e NGINX_RESTART MONGODB_RESTART LDAP_RESTART PHP_FPM_RESTART
$S systemctl daemon-reload
if [ -n "$SERVICE" ]; then
    $S systemctl restart $SERVICE
fi

#删除变量
array=`cat .env | sed -n -e '/[a-zA-Z].*=/p' | tr -d ' ' | grep -v -e ";" -e "^#" | cut -d'=' -f1 | uniq`
unset ${array[@]}
unset SERVICE

#删除函数
array=`cat base.sh | sed -n -e '/function /p'  | cut  -d'(' -f1  | cut -d' ' -f2`
unset -f ${array[@]}
