#!/bin/bash

if [ "$USER" != "root" ]; then
    S=sudo
fi

if [  x"$SERVICE_DIR" == x ];then 
    SERVICE_DIR=`systemctl status systemd-initctl | grep -e Loaded | cut  -d';' -f1 | cut -d'(' -f2`
    SERVICE_DIR=${SERVICE_DIR%/*}
fi

if [  x"$RELEASE" == x ];then 
    lsb_release -a 2>/dev/null >/dev/null || preinstall_yum redhat-lsb || preinstall_apt lsb_release
    if [ "$(lsb_release -is)" == "CentOS" ]; then
        RELEASE=$(lsb_release -rs)
        RELEASE=rhel${RELEASE:0:1}0
    elif [ "$(lsb_release -is)" == "Ubuntu" ]; then
        RELEASE=$(lsb_release -rs)
        RELEASE=ubuntu${RELEASE//./}
    fi
fi


function ist(){
    for var in $@
    do
        eval [ "\$$1" != "true" ] && return 1
    done
    return 0
}


function e(){
    for var in $@
    do
        if ist $@; then
            printf "\033[34m[set]\033[0m "
            eval printf "$var\ "
            eval var=\$$var    # eval echo -e 不能变颜色
            
            if [ "$var" == "true" ]; then
                printf "\033[32m$var\033[0m"
            elif [ "$var" == "false" ]; then
                printf "\033[31m$var\033[0m"
            fi
            printf "\n"
        fi
    done
}
function info(){
    echo -e "\033[34m[INFO] \033[0m $@"
}

# ret 解压地址 : $1 类型        $2 文件夹名 $3 包名，    $4 下载地址
# ret         : tar.gz|tgz     $2 文件夹名 $3 包名，    $4 下载地址
# ret         : git            $2 文件夹名 $3 下载地址  $4 git参数 
function check() {
    if [[ $# -gt 2 && ! -d $TAR_DIR/$2 ]]; then
        case $1 in 
            tar.gz)
                [ ! -e $TAR_DIR/$3 ] && wget $4 -P $TAR_DIR 2>&1 >/dev/null
                tar -xvf $TAR_DIR/$3 -C $TAR_DIR 2>&1 >/dev/null
                ;;
            tgz)
                [ ! -e $TAR_DIR/$3 ] && wget $4 -P $TAR_DIR 2>&1 >/dev/null
                tar -zxvf $TAR_DIR/$3 -C $TAR_DIR 2>&1 >/dev/null
                ;;
            git)
                
                git clone $3 $TAR_DIR/$2 ${@:4}
                ;;           
            *)
                ;;
        esac
        echo $TAR_DIR/$2
    elif [[ $# -gt 2 && -d $TAR_DIR/$2 ]]; then
        echo $TAR_DIR/$2
    elif [[ $# -eq 1 && -d $TAR_DIR/$1 ]]; then
        echo  $TAR_DIR/$1
    fi
}

function isactive() {
     [ "$($S systemctl is-active $1)" == "active" ] || return 0
     return 1
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
        if dpkg-query -l $@ >/dev/null; then
            return 0
        fi
        if ist PACKAGE_INFO_SHOW; then
            $S apt-get -y  install $@
        else
            $S apt-get -y install $@ >>install.msg
        fi
    fi
}

function preinstall_yum(){
    if [ "$DistribuID" == "CentOS" ]; then
        if ist PACKAGE_INFO_SHOW; then
            $S yum -y  install $@
        else
            $S yum -y  install $@ >>install.msg
        fi
    fi
}

function setgithubdns()
{
    grep "github.com" /etc/hosts >/dev/null
    if [ $? -ne 0 ]; then
        $S chmod a+w /etc/hosts
        $S echo "192.30.255.113    github.com"  >>/etc/hosts
        ping -c 1 -w 1 github.com || echo "连接github失败" && exit 1
    fi
}

