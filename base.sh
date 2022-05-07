#!/bin/bash

source .env

if [ "$USER" != "root" ]; then
    S=sudo
fi

if [  x"$SERVICE_DIR" == x ];then 
    SERVICE_DIR=`systemctl status systemd-initctl | grep -e Loaded | cut  -d';' -f1 | cut -d'(' -f2`
    SERVICE_DIR=${SERVICE_DIR%/*}
fi

function e(){
    if [ "$2" == "true" ]; then
        echo -e "\033[34m[env] \033[0m $1 \033[32m$2\033[0m"
    elif  [ "$2" == "false" ]; then
        echo -e "\033[34m[env] \033[0m $1 \033[31m$2\033[0m"
    fi
}
function info(){
    echo -e "\033[34m [INFO] \033[0m $@"
}
function preinstall()
{   
    lsb_release -a || preinstall_yum redhat-lsb || preinstall_apt lsb_release
    DistribuID=$(lsb_release -is)
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
    unset DistribuID
}

function preinstall_apt()
{
    if [ "$PACKAGE_INFO_SHOW" == "true" ]; then
        $S apt-get -y  install $@
    else
        $S apt-get  install $@ >install.msg
    fi
}

function preinstall_yum(){
    if [ "$PACKAGE_INFO_SHOW" == "true" ]; then
        $S yum -y  install $@
    else
        $S yum -y  install $@ >install.msg
    fi
}

function clean()
{
    array=`cat .env | sed -n -e '/[a-zA-Z].*=/p' | tr -d ' ' | grep -v -e ";" -e "^#" | cut -d'=' -f1 | uniq`
    unset ${array[@]}
}