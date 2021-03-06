#!/bin/bash

source $D/../bin/base.sh
source $D/.env

if istrue MONGOD_UPDATE_SERVICE; then
    $S cp -f $(pwd)/$D/mongod.service $SERVICE_DIR/mongod.service
fi

if istrue MONGOD_INSTALL_PKG; then

    `check tgz $MONGOD_NAME $MONGOD_NAME.tar.gz https://fastdl.mongodb.org/linux/$MONGOD_NAME.tgz` || exit $?
    isactive mongod ||  $S systemctl stop mongod
    $S rm -rf /usr/local/mongodb
    $S cp -r $TAR_DIR/$MONGOD_NAME /usr/local/mongodb
    $S mkdir -p /var/{lib/mongodb,log/mongodb}
    $S touch /var/log/mongodb/mongodb.log
fi


if istrue MONGOD_UPDATE_CONFIG; then
    $S cp -f $(pwd)/$D/mongod.conf /usr/local/mongodb/mongod.conf
fi
