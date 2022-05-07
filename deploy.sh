#!/bin/bash

set -e

source base.sh

preinstall wget curl gcc make 

source nginx/setup.sh
source mongodb/setup.sh
source slapd/setup.sh

SERVICE=""
if [ "$NGINX_RESTART" == "true" ]; then
    SERVICE+=" nginx"
fi
if [ "$MONGODB_RESTART" == "true" ]; then
    SERVICE+=" mongodb"
fi
if [ "$LDAP_RESTART" == "true" ]; then
    SERVICE+=" mongodb"
fi

e "NGINX_RESTART" "$NGINX_RESTART"
e "MONGODB_RESTART" "$MONGODB_RESTART"
e "LDAP_RESTART" "$LDAP_RESTART"
$S systemctl daemon-reload
if [ -n "$SERVICE" ]; then
    $S systemctl restart $SERVICE
fi



unset SERVICE
clean
