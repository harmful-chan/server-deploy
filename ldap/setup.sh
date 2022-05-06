#!/bin/bash

source .env

if [ ! -d $TAR_DIR/$LDAP_NAME ]; then
    git clone --depth 1 https://git.openldap.org/openldap/$LDAP_NAME.git $TAR_DIR/$LDAP_NAME
fi

if [ "$LDAP_BUILD" == "true" ]; then
    cd $TAR_DIR/$LDAP_NAME
    ./configure
    make depend
    make -j2 

    info "stop slapd service."
    if [ "$(systemctl is-active slapd)" == "active" ]; then
        $S systemctl stop slapd
    fi
    info "copy slapd dependent file."
        
    # 执行文件 /usr/local/libexec/slapd
    # 配置模板 /usr/local/etc/openldap/slapd.conf
    # 配置文件 /usr/local/etc/slapd.d/*
    $S make install
    cd -

    $S mkdir /usr/local/etc/slapd.d
    $S mkdir /usr/local/var/openldap-data

    # 初始化配置文件。slapd.ldif 修改了，管理员账户号：Manager,dc=hans,dc=org，密码：123456
    $S slapadd -n 0 -F /usr/local/etc/slapd.d -l slapd.ldif    
    # 启动服务
    $S /usr/local/libexec/slapd -F /usr/local/etc/slapd.d

    # 创建两条记录
    # 根 hans.org
    # 管理员 Manager.hans.org
    $S sldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f entry.ldif 

    # 导入员工信息
    $S sldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f group.ldif 
    $S sldapadd -x -D "cn=Manager,dc=hans,dc=org" -w 123456 -f people.ldif 

fi