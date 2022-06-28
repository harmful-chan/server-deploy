#!/bin/bash

set -e

source base.sh
source .env

rm -f install.msg
preinstall wget curl gcc make git
setgithubdns

#../bind9/setup.sh

for setup in $( find .. -name 'setup.sh' | grep -v '../bin/setup.sh')
do
    D=$(dirname $setup)
    source $setup
done

./clean.sh
