#!/bin/bash

sleep 10000
cd /data/dev
. setenv.sh
pkill -9 -f ccnet-server
pkill -9 -f seaf-server
pkill -9 -f runserver
ccnet-server -c /root/seafile/conf -D all -L /root/seafile -f - >/root/seafile/logs/ccnet.log 2>&1 &
sleep 0.5
seaf-server -c /root/seafile/conf -d /root/seafile/conf/seafile-data -D all -f -l - >/root/seafile/logs/seafile.log 2>&1 &
sleep 0.5
cd seahub
nohup python manage.py runserver 0.0.0.0:8000 2>&1 > /root/seafile/logs/seahub-runtime.log &
cd ../seafevents
nohup python main.py --config-file /root/seafile/conf/seafevents.conf 2>&1 > /root/seafile/logs/seafevents.log &


sleep 10000

function check_process(){
    # check the args
    if [ "$1" = "" ];
    then
        return 0
    fi

    #PROCESS_NUM => get the process number regarding the given thread name
    PROCESS_NUM=$(ps -ef | grep "$1" | grep -v "grep" | wc -l)
    # for degbuging...
    $PROCESS_NUM
    if [ $PROCESS_NUM -eq 1 ];
    then
    	return 1
    else
        echo "$1 already exit"
        exit 1
    fi
}

while [ 1 ] ; do
        check_process "ccnet-server"
        check_process "seaf-server"
        check_process "manage.py runserver"
        sleep 10
done
