#!/bin/bash

source $D/../bin/base.sh
source $D/.env

if istrue MYSQL8_UPDATE_SERVICE; then
    $S cp -f $(pwd)/$D/mysql8.service $SERVICE_DIR/mysql8.service
fi

if istrue MYSQL8_INSTALL_PKG; then

    echo `check tar.zx $MYSQL8_NAME $MYSQL8_NAME.tar.zx https://dev.mysql.com/get/Downloads/MySQL-8.0/ $MYSQL8_NAME.tar.xz` || exit $?
    isactive mysql8 &&  $S systemctl stop mysql8
    $S rm -rf /usr/local/mysql8
    $S cp -r `check $MYSQL8_NAME` /usr/local/mysql8
    

    $S rm -rf /var/lib/mysql8/data
    $S mkdir -p /var/lib/mysql8/data
    $S mkdir -p /var/log/mysql8
    $S mkdir -p /var/run/mysql8
    $S rm -rf /var/log/mysql8/mysqld.log
    $S touch /var/log/mysql8/mysqld.log
    $S touch /var/run/mysql8/mysqld.pid

    # 创建用户 mysql uid=113, group gid=119
    groups mysql  || groupadd -g 119 mysql
    id mysql || useradd -u 113 -g mysql mysql
    $S chown -R mysql:mysql /var/lib/mysql8
    $S chown -R mysql:mysql /var/log/mysql8
    $S chown -R mysql:mysql /var/run/mysql8
    $S chown -R mysql:mysql /usr/local/mysql8

    # 初始化数据库
    # 默认创建'root'@'%'密码为空
    $S /usr/local/mysql8/bin/mysqld --defaults-file=$(pwd)/$D/conf/my.cnf  --initialize-insecure  
fi

if istrue MYSQL8_INIT_ROOT; then
    isactive mysql8 ||  $S systemctl start mysql8

    # 设置 'root'@'%' 密码 123456
    /usr/local/mysql8/bin/mysql --defaults-file=$(pwd)/$D/conf/my.cnf -uroot -h127.0.01 mysql \
        -e "ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456';"
    # 添加 'root'@'%' 权限
    /usr/local/mysql8/bin/mysql --defaults-file=$(pwd)/$D/conf/my.cnf -uroot -h127.0.01 -p123456 mysql \
        -e "grant all privileges on *.* to root@'%';"
    $S systemctl stop mysql8
fi

if istrue MYSQL8_UPDATE_CONFIG; then
    $S cp -f $D/conf/my.cnf /etc/my.cnf
fi
