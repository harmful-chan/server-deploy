#!/bin/bash

function pstatus()
{
    # 第8个参数开始死活不能当作一个字符串传给prinf只能用%s凑数 /(ㄒoㄒ)/~~
    printf "%-10s%-6s%-6s%-6s%-10s%-10s%-30s%s %s %s %s %s\n" ${@:1:7} "${@:8}"
}


SERVICE="slapd|nginx|mongod|php-fpm"
OLD_IFS=$IFS
IFS=' '
ps=`sudo ps -aux | grep -E $SERVICE | grep -v 'grep'`
pss=`echo $ps | awk  '{print $1,$2,$3,$4,$6,$9 }'`
nets=`sudo netstat -antup | grep -E $SERVICE`

pstatus "user" "pid" "cup" "mem" "mensize"  "time" "net" "name"
echo $pss |
while read user pid cpu mem mens stime; do
    ip=`echo $nets | grep -e "$pid/" | awk '{print $4}'`
    name=`echo $ps | grep $pid | tr -s ' ' | cut -d ' ' -f11-`
    mens=$(printf "%.2f" $(echo "scale=2;$mens/1024"|bc))M
    array=($user $pid $cpu% $mem% $mens $stime)
    array[6]=`echo $ip  | sed ":a;N;s/\n/\//g;ta"`
    [ -z "$ip" ] &&  array[6]=-
    array[7]=$name 
    pstatus ${array[@]}
done 

unset ps pss nets ip name array SERVICE
unset -f pstatus
IFS=$OLD_IFS