#!/bin/bash



for d in $( find .. -name '.env')
do 
    printf "\n+ %s<br>\n" "$(dirname ${d#*/})" >>../README.md
    sed '/^#/d;/^$/d' $d |
    while read line 
    do
        A=$(echo $line |  cut -d'=' -f1)
        B=$(echo $line |  cut -d'#' -f2 | tr -s ' ')
        printf "\`%s\`:%s<br>\n" $A "$B" >>../README.md
    done
done