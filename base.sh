#!/bin/bash

if [ "$USER" != "root" ]; then
    S=sudo
fi

if [  x"$SERVICE_DIR" == x ];then 
    SERVICE_DIR=`systemctl status systemd-initctl | grep -e Loaded | cut  -d';' -f1 | cut -d'(' -f2`
    SERVICE_DIR=${SERVICE_DIR%/*}
fi

if [  x"$RELEASE" == x ];then 
    lsb_release -a || preinstall_yum redhat-lsb || preinstall_apt lsb_release
    if [ "$(lsb_release -is)" == "CentOS" ]; then
        RELEASE=$(lsb_release -rs)
        RELEASE=rhel${RELEASE:0:1}0
    elif [ "$(lsb_release -is)" == "Ubuntu" ]; then
        RELEASE=$(lsb_release -rs)
        RELEASE=ubuntu${RELEASE//./}
    fi
fi


function e(){
    for var in $@
    do
        printf "\033[34m[env]\033[0m "
        eval printf "$var\ "
        eval var=\$$var    # eval echo -e 不能变颜色
        if [ "$var" == "true" ]; then
            printf "\033[32m$var\033[0m"
        elif [ "$var" == "false" ]; then
            printf "\033[31m$var\033[0m"
        fi
        printf "\n"
    done
}
function info(){
    echo -e "\033[34m[INFO] \033[0m $@"
}

function istrue(){
    eval e $@
    for var in $@
    do
        eval [ "\$$1" != "true" ] && return 1
    done
    return 0
}
function preinstall()
{   
    
    [ x"$DistribuID" == x ] && DistribuID=$(lsb_release -is)
    if [ "$DistribuID" == "CentOS" ]; then
        preinstall_yum $@
        INSTALLER=${INSTALLER:=yum}
    elif [ "$DistribuID" == "Ubuntu" ]; then
        preinstall_apt $@
        INSTALLER=${INSTALLER:=apt-get}
    else
        echo "系统未能识别，Distributor ID:$DistribuID"
        exit 1
    fi
}

function preinstall_apt()
{
    if [ "$DistribuID" == "Ubuntu" ]; then
        if [ "$PACKAGE_INFO_SHOW" == "true" ]; then
            $S apt-get -y  install $@
        else
            $S apt-get -y install $@ >>install.msg
        fi
    fi
}

function preinstall_yum(){
    if [ "$DistribuID" == "CentOS" ]; then
        if [ "$PACKAGE_INFO_SHOW" == "true" ]; then
            $S yum -y  install $@
        else
            $S yum -y  install $@ >>install.msg
        fi
    fi
}

source .env