#!/bin/bash

source $D/../bin/base.sh
source $D/.env

if istrue LDAP_UPDATE_SERVICE; then
    $S ln -sf $(pwd)/$D/slapd.service $SERVICE_DIR/slapd.service
fi

if istrue LDAP_COMPILE_SRC; then

    cd `check git openldap https://git.openldap.org/openldap/openldap.git  --depth 1`

    if ist LDAP_CONF_OPENSS; then
        ./configure --prefix=/usr/local/openldap CPPFLAGS="-I/usr/local/openssl/include"  LDFLAGS="-L/usr/local/openssl/lib"
    else
        ./configure --prefix=/usr/local/openldap
    fi
    make depend
    make -j2 
    cd -
fi

if istrue LDAP_INSTALL_SRC; then
    cd `check openldap ` 
    isactive slapd &&  $S systemctl stop slapd
    $S rm -rf /usr/local/openldap
    $S make install
    cd -
fi

if istrue LDAP_UPDATE_CONFIG; then
    $S mkdir -p /etc/openldap/slapd.d
    $S mkdir -p /var/lib/openldap/data
    # 初始化配置文件。slapd.ldif 修改了，管理员账户号：Manager,dc=hans,dc=org，密码：123456
    $S rm -rf /etc/openldap/slapd.d/*
    $S slapadd -n 0 -F /etc/openldap/slapd.d -l $D/conf/slapd.ldif    
fi

if istrue LDAP_LOAD_DEMO; then
    isactive slapd ||  $S systemctl start slapd
    # 创建两条记录
    # 根 hans.org
    # 管理员 Manager.hans.org
    $S ldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f $D/conf/entry.ldif 
    # 导入员工信息
    $S ldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f $D/conf/group.ldif 
    $S ldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f $D/conf/people.ldif 

    $S systemctl stop slapd
fi
