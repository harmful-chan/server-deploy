#!/bin/bash

acti=$(echo $1 | tr a-z A-Z)
filetype=$(echo $2 | tr a-z A-Z)
for server in ${@:3}
do
    name=$(echo $server | tr a-z A-Z)
    eval ${name}_${acti}_${filetype}=true
done
source setup.sh