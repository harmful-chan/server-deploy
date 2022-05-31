#!/bin/bash

source $(dirname $BASH_SOURCE)/../bin/base.sh
source $(dirname $BASH_SOURCE)/.env

if istrue OPENVPN_INSTALL_BIN; then
    preinstall openvpn
fi

if istrue OPENVPN_GEN_CERT; then
    WORK_DIR=$(pwd)

    preinstall expect # 用来写交互脚本的工具

    cd `check git easy-rsa https://github.com/OpenVPN/easy-rsa.git  -b release/2.x --depth=1` || exit $?
    cd easy-rsa/2.0

    # 定义 国家 省份 市 组织等 基本信息进环境变量。
    cp  $WORK_DIR/$(dirname $BASH_SOURCE)/vars vars
    source vars
    ./clean-all
    cp openssl-1.0.0.cnf openssl.cnf
    
    
    # ca.crt ca.key
    echo -e '\n\n\n\n\n\n\n\n' | ./build-ca

    # node.crt node.key server.crt server.key 
    expect $WORK_DIR/$(dirname $BASH_SOURCE)/cs_exp.sh build-key-server server
    for i in {1..5}; do
        expect $WORK_DIR/$(dirname $BASH_SOURCE)/cs_exp.sh build-key node$i
    done
    # dh2018.pem
    ./build-dh

    # 拷贝到conf目录
    cp -f keys/server.crt keys/server.key  keys/ca.crt keys/dh2048.pem \
        $WORK_DIR/$(dirname $BASH_SOURCE)/conf/server
    cp -f keys/node*.crt keys/node*.key  keys/ca.crt \
        $WORK_DIR/$(dirname $BASH_SOURCE)/conf/client
    
    cd $WORK_DIR

    unset WORK_DIR
fi

if istrue OPENVPN_UPDATE_CONFIG; then

    # ta.key
    openvpn --genkey --secret $(dirname $BASH_SOURCE)/conf/server/ta.key  
    cp -f $(dirname $BASH_SOURCE)/conf/server/ta.key  \
        $(dirname $BASH_SOURCE)/conf/client/ta.key 
    
    # client.conf 生成 5台节点的配置文件
    for i in {1..5}; do
        sed -e "/^cert/s/client/node$i/2;/^key/s/client/node$i/2" \
            $(dirname $BASH_SOURCE)/conf/client.conf  \
            >$(dirname $BASH_SOURCE)/conf/node$i.conf
    done

    $S cp -rf  $(dirname $BASH_SOURCE)/conf/* /etc/openvpn/
fi

if istrue OPENVPN_UPDATE_SERVICE; then
    $S cp -f $(pwd)/$(dirname $BASH_SOURCE)/bind9.service $SERVICE_DIR/bind9.service
fi