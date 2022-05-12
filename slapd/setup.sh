#!/bin/bash

source $(dirname $BASH_SOURCE)/../base.sh

if istrue OPENSSL_BUILD; then
    if [ ! -e $TAR_DIR/openssl-1.1.1.tar.gz ]; then
        wget https://www.openssl.org/source/openssl-1.1.1.tar.gz -P $TAR_DIR
    fi
    if [ ! -d $TAR_DIR/openssl-1.1.1 ]; then
        tar -xvf $TAR_DIR/openssl-1.1.1.tar.gz -C $TAR_DIR
    fi
    $S rm -rf /usr/local/openssl
    cd $TAR_DIR/openssl-1.1.1
    ./config --prefix=/usr/local/openssl
    make -j2 
    $S make install
    $S mv /usr/bin/openssl /usr/bin/openssl.bak
    $S ln -sf /usr/local/openssl/bin/openssl /usr/bin/openssl
    if [ "$(tail -n1 /etc/ld.so.conf)" != "/usr/local/openssl/lib" ]; then
        echo "/usr/local/openssl/lib" >>  /etc/ld.so.conf 
    fi
    $S ldconfig -v
    cd -
fi

if istrue LDAP_MAKE; then
    if [ ! -d $TAR_DIR/$LDAP_NAME ]; then
        git clone --depth 1 https://git.openldap.org/openldap/$LDAP_NAME.git $TAR_DIR/$LDAP_NAME
    fi
    cd $TAR_DIR/$LDAP_NAME
    if [ "$LDAP_CONF_OPENSS" == "true" ]; then
        ./configure --prefix=/usr/local/openldap CPPFLAGS="-I/usr/local/openssl/include"  LDFLAGS="-L/usr/local/openssl/lib"
    else
        ./configure --prefix=/usr/local/openldap
    fi
    make depend
    make -j2 
    cd -
fi

if istrue LDAP_INSTALL; then
    cd $TAR_DIR/$LDAP_NAME
    if [ "$(systemctl is-active slapd)" == "active" ]; then
        $S systemctl stop slapd
    fi
    $S rm -rf /usr/local/openldap
    $S make install
    $S mkdir -p /etc/openldap/slapd.d
    $S mkdir -p /var/lib/openldap/data
    cd -
fi

if istrue LDAP_UPDATE_CONFIG; then
    # 初始化配置文件。slapd.ldif 修改了，管理员账户号：Manager,dc=hans,dc=org，密码：123456
    $S rm -rf /etc/openldap/slapd.d/*
    $S slapadd -n 0 -F /etc/openldap/slapd.d -l $(dirname $BASH_SOURCE)/slapd.ldif    
fi

if istrue LDAP_UPDATE_SERVICE; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/slapd.service $SERVICE_DIR/slapd.service
fi

if istrue LDAP_LOAD_DEMO; then
    if [ "$(systemctl is-active slapd)" != "active" ]; then
        $S systemctl start slapd
    fi

    # 创建两条记录
    # 根 hans.org
    # 管理员 Manager.hans.org
    $S ldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f $(dirname $BASH_SOURCE)/entry.ldif 
    # 导入员工信息
    $S ldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f $(dirname $BASH_SOURCE)/group.ldif 
    $S ldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f $(dirname $BASH_SOURCE)/people.ldif 

    $S systemctl stop slapd
fi
