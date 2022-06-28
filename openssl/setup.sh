#!/bin/bash

source $D/../bin/base.sh
source $D/.env

if istrue OPENSSL_COMPILE_SRC; then

    cd `check tar.gz openssl-1.1.1 openssl-1.1.1.tar.gz https://www.openssl.org/source/openssl-1.1.1.tar.gz`
    ./config --prefix=/usr/local/openssl
    make -j2 
    cd -
fi

if istrue OPENSSL_INSTALL_SRC; then
    cd `check openssl-1.1.1 ` 
    $S rm -rf /usr/local/openssl
    $S make install
    cd -
fi

if istrue OPENSSL_LINK_BIN; then
    $S mv /usr/bin/openssl /usr/bin/openssl.bak    
    $S ln -sf /usr/local/openssl/bin/openssl /usr/bin/openssl
fi


if istrue OPENSSL_LOAD_SO; then
    ## 重新加载动态库
    [ ! -e /etc/ld.so.conf.d/openssl.conf ] && \
        echo "/usr/local/openssl/lib" | $S tee -a /etc/ld.so.conf.d/openssl.conf
    $S ldconfig
fi