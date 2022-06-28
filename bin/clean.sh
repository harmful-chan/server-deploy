#!/bin/bash

#删除变量
for d in $( find .. -name '.env')
do 
    unset $(cat $d | cut -d'=' -f1 | sed '/^#/d;/^$/d')
done
unset SERVICE


#删除函数
array=`cat base.sh | sed -n -e '/function /p'  | cut  -d'(' -f1  | cut -d' ' -f2`
unset -f ${array[@]}