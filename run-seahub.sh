#!/bin/bash

. setenv.sh
pkill -9 -f ccnet-server
pkill -9 -f seaf-server
pkill -9 -f runserver
ccnet-server -c /opt/conf -D all -L /root -f - >/tmp/ccnet.log 2>&1 &
sleep 0.5
seaf-server -c /opt/conf -d /opt/conf/seafile-data -D all -f -l - >/tmp/seafile.log 2>&1 &
sleep 0.5
python manage.py runserver 0.0.0.0:8000
