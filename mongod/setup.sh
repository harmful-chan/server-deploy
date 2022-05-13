#!/bin/bash

source $(dirname $BASH_SOURCE)/../base.sh

if istrue MONGOD_UPDATE_SERVICE; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/mongod.service $SERVICE_DIR/mongod.service
fi

if istrue MONGOD_INSTALL; then
    if [ ! -e $TAR_DIR/$MONGOD_NAME.tgz ]; then
        wget https://fastdl.mongodb.org/linux/$MONGOD_NAME.tgz -P $TAR_DIR
    fi
    if [ ! -d $TAR_DIR/$MONGOD_NAME.tgz ]; then
        tar -zxvf $TAR_DIR/$MONGOD_NAME.tgz -C $TAR_DIR
    fi

    if [ "$(systemctl is-active mongodb)" == "active" ]; then
        $S systemctl stop mongodb
    fi
    $S rm -rf /usr/local/mongodb
    $S cp -r $TAR_DIR/$MONGOD_NAME /usr/local/mongodb
    $S mkdir -p /var/{lib/mongodb,log/mongodb}
    $S touch /var/log/mongodb/mongodb.log
fi


if istrue MONGOD_UPDATE_CONFIG; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/mongod.conf /usr/local/mongodb/mongod.conf
fi


