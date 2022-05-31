#!/usr/bin/expect -f
set timeout 1
spawn ./build-ca 
expect "Country Name (2 letter code) \[cn\]:"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
expect eof