#!/bin/bash

PROCNAME=$1

function stop_proc() {
  /etc/init.d/$PROCNAME stop
  exit
}

trap stop_proc SIGINT SIGTERM

/etc/init.d/$PROCNAME start 

while true; do 
 if ps -ax | grep [0-9]\ /usr/bin/java | grep -q $2 ; then 
   sleep 5
 else
   exit
 fi

done
