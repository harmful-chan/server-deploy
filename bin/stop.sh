#!/bin/bash

SERVICE=''
for dir in $( find .. -name 'setup.sh' | grep -v '../bin/setup.sh')
do
    SERVICE+="$(dirname ${dir#*/}) "
done
sudo systemctl stop $SERVICE
unset SERVICE