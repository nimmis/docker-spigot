#!/bin/bash

function stop_minecraft() {
  /etc/init.d/$1 stop
  exit
}

trap stop_minecraft SIGINT SIGTERM

/etc/init.d/$1 start 

while true; do 
 if ps -ax | grep [0-9]\ /usr/bin/java | grep -q $2 ; then 
   sleep 5
 else
   exit
 fi

done
