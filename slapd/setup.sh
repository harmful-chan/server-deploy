#!/bin/bash

source $(dirname $BASH_SOURCE)/../base.sh



e "OPENSSL_BUILD" "$OPENSSL_BUILD"
if [ "$OPENSSL_BUILD" == "true" ]; then
    if [ ! -e $TAR_DIR/openssl-1.1.1g.tar.gz ]; then
        wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz -P $TAR_DIR
    fi
    if [ ! -d $TAR_DIR/openssl-1.1.1g ]; then
        tar -xvf $TAR_DIR/openssl-1.1.1g.tar.gz -C $TAR_DIR
    fi
    cd $TAR_DIR/openssl-1.1.1g
    ./config --prefix=/usr/local/openssl
    make -j2 
    $S make install
    $S mv /usr/bin/openssl /usr/bin/openssl.bak
    $S ln -sf /usr/local/openssl/bin/openssl /usr/bin/openssl
    if [ $(tail -n1 /etc/ld.so.conf) != "/usr/local/openssl/lib" ]; then
        echo "/usr/local/openssl/lib" >>  /etc/ld.so.conf 
    fi
    $S ldconfig -v
    cd -
fi

e "LDAP_MAKE" "$LDAP_MAKE"
if [ "$LDAP_MAKE" == "true" ]; then

    if [ ! -d $TAR_DIR/$LDAP_NAME ]; then
        git clone --depth 1 https://git.openldap.org/openldap/$LDAP_NAME.git $TAR_DIR/$LDAP_NAME
    fi
    cd $TAR_DIR/$LDAP_NAME
    ./configure --prefix=/
    make depend
    make -j2 
    cd -
fi

e "LDAP_INSTALL" "$LDAP_INSTALL"
if [ "$LDAP_INSTALL" == "true" ]; then
    cd $TAR_DIR/$LDAP_NAME
    if [ "$(systemctl is-active slapd)" == "active" ]; then
        $S systemctl stop slapd
    fi
    $S make install
    $S mkdir -f /etc/openldap/slapd.d
    $S mkdir -f /var/lib/openldap/data
    cd -
fi

e "LDAP_UPDATE_CONFIG" "$LDAP_UPDATE_CONFIG"
if [ "$LDAP_UPDATE_CONFIG" == "true" ]; then
    # 初始化配置文件。slapd.ldif 修改了，管理员账户号：Manager,dc=hans,dc=org，密码：123456
    $S slapadd -n 0 -F /etc/openldap/slapd.d -l $(dirname $BASH_SOURCE)/slapd.ldif    
fi

e "LDAP_UPDATE_SERVICE" "$LDAP_UPDATE_SERVICE"
if [ "$LDAP_UPDATE_SERVICE" == "true" ]; then
    $S ln -sf $(pwd)/$(dirname $BASH_SOURCE)/sladp.service $SERVICE_DIR/sladp.service
fi

e "LDAP_LOAD_DEMO" "$LDAP_LOAD_DEMO"
if [ "$LDAP_LOAD_DEMO" == "true" ]; then
    # 创建两条记录
    # 根 hans.org
    # 管理员 Manager.hans.org
    $S sldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f $(dirname $BASH_SOURCE)/entry.ldif 
    # 导入员工信息
    $S sldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f $(dirname $BASH_SOURCE)/group.ldif 
    $S sldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f $(dirname $BASH_SOURCE)/people.ldif 
fi
