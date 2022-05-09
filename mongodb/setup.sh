#!/bin/bash

source $(dirname $BASH_SOURCE)/../base.sh

if istrue MONGODB_INSTALL; then
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


if istrue MONGODB_UPDATE_CONFIG; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/mongodb.conf /usr/local/mongodb/mongodb.conf
fi

if istrue MONGODB_UPDATE_SERVICE; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/mongodb.service $SERVICE_DIR/mongodb.service
fi
