#!/bin/bash

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
sleep 1000
