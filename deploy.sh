#!/bin/bash

set -e

source base.sh

rm -f install.msg
preinstall wget curl gcc make 

source nginx/setup.sh
source mongod/setup.sh
source slapd/setup.sh

SERVICE=""
if [ "$NGINX_RESTART" == "true" ]; then
    SERVICE+=" nginx"
fi
if [ "$MONGODB_RESTART" == "true" ]; then
    SERVICE+=" mongod"
fi
if [ "$LDAP_RESTART" == "true" ]; then
    SERVICE+=" slapd"
fi

e NGINX_RESTART MONGODB_RESTART LDAP_RESTART
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
