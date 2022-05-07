#!/bin/bash

source $(dirname $BASH_SOURCE)/../base.sh




e "MONGODB_INSTALL" "$MONGODB_INSTALL"
if [ "$MONGODB_INSTALL" == "true" ]; then
    if [ ! -e $TAR_DIR/$MONGODB_NAME.tgz ]; then
        wget https://fastdl.mongodb.org/linux/$MONGODB_NAME.tgz -P $TAR_DIR
    fi
    if [ ! -d $TAR_DIR/$MONGODB_NAME.tgz ]; then
        tar -zxvf $TAR_DIR/$MONGODB_NAME.tgz -C $TAR_DIR
    fi

    if [ "$(systemctl is-active mongodb)" == "active" ]; then
        $S systemctl stop mongodb
    fi
    $S rm -rf /usr/local/mongodb
    $S cp -r $TAR_DIR/$MONGODB_NAME /usr/local/mongodb
    $S mkdir -p /var/{lib/mongodb,log/mongodb}
    $S touch /var/log/mongodb/mongodb.log
fi


e "MONGODB_UPDATE_CONFIG" "$MONGODB_UPDATE_CONFIG"
if [ "$MONGODB_UPDATE_CONFIG" == "true" ]; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/mongodb.conf /usr/local/mongodb/mongodb.conf
fi

e "MONGODB_UPDATE_SERVICE" "$MONGODB_UPDATE_SERVICE"
if [ "$MONGODB_UPDATE_SERVICE" == "true" ]; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/mongodb.service $SERVICE_DIR/mongodb.service
fi
