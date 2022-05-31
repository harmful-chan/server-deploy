#!/bin/bash

set -e

source base.sh
source .env

rm -f install.msg
preinstall wget curl gcc make git
setgithubdns

#../bind9/setup.sh

for dir in $( find .. -name 'setup.sh' | grep -v '../bin/setup.sh')
do
    source $dir
done

#删除变量
for d in $( find .. -name '.env')
do 
    unset $(cat $d | cut -d'=' -f1 | sed '/^#/d;/^$/d')
done
unset SERVICE


#删除函数
array=`cat base.sh | sed -n -e '/function /p'  | cut  -d'(' -f1  | cut -d' ' -f2`
unset -f ${array[@]}
