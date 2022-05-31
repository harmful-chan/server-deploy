#!/usr/bin/expect -f
set BIN     [lindex $argv 0] 
set NAME    [lindex $argv 1] 
set timeout 1

spawn ./$BIN $NAME 
expect "Country Name (2 letter code) \[cn\]:"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "y\n"
send "y\n"
expect eof