#!/bin/bash

. setenv.sh
pkill -9 -f ccnet-server
pkill -9 -f seaf-server
pkill -9 -f runserver
ccnet-server -c /root/dev/conf -D all -L /root -f - >/tmp/ccnet.log 2>&1 &
sleep 0.5
seaf-server -c /root/dev/conf -d /root/dev/conf/seafile-data -D all -f -l - >/tmp/seafile.log 2>&1 &
sleep 0.5
cd seahub
nohup python manage.py runserver 0.0.0.0:8000 2>&1 > /tmp/seahub-runtime.log &
cd ../seafevents
nohup python main.py 2>&1 > /tmp/seafevents.log &
