#!/bin/bash

#set -e

source_prefix=/root/seafile/migrate/source

function stop_server() {
    pkill -9 -f ccnet-server
    pkill -9 -f seaf-server
    pkill -9 -f runserver
    pkill -9 -f main
}

function set_env() {
    export CCNET_CONF_DIR=/root/seafile/conf
    export SEAFILE_CONF_DIR=/root/seafile/conf/seafile-data
    export PYTHONPATH=/usr/lib/python2.7/dist-packages:/usr/lib/python2.7/site-packages:/usr/local/lib/python2.7/dist-packages:/usr/local/lib/python2.7/site-packages:/root/seafile/dev/seahub/thirdpart:/root/seafile/dev/pyes/pyes:/root/seafile/dev/seahub-extra::/root/seafile/dev/portable-python-libevent/libevent:/root/seafile/dev/seafobj:/root/seafile/dev/:/root/seafile/dev/seahub/seahub/:$PYTHONPATH
    export SEAFES_DIR=/root/seafile/dev/seafes/
}

function start_server() {
    stop_server

    set_env

    nohup ccnet-server -c /root/seafile/conf -D all -L /root/seafile -f - >/root/seafile/logs/ccnet.log 2>&1 &
    sleep 0.5
    nohup seaf-server -c /root/seafile/conf -d /root/seafile/conf/seafile-data -D all -f -l - >/root/seafile/logs/seafile.log 2>&1 &
    sleep 0.5
    cd /data/dev/seahub
    nohup python manage.py runserver 0.0.0.0:8000 2>&1 > /root/seafile/logs/seahub-runtime.log &
    cd ../seafevents
    sleep 0.5
    nohup python main.py --config-file /root/seafile/conf/seafevents.conf 2>&1 > /root/seafile/logs/seafevents.log &
    # Seafevents cannot start without sleep for a few seconds
    sleep 2
}

function check_python_executable() {
    if [[ "$PYTHON" != "" && -x $PYTHON ]]; then
        return 0
    fi

    if which python2.7 2>/dev/null 1>&2; then
        PYTHON=python2.7
    elif which python27 2>/dev/null 1>&2; then
        PYTHON=python27
    else
        echo
        echo "Can't find a python executable of version 2.7 or above in PATH"
        echo "Install python 2.7+ before continue."
        echo "Or if you installed it in a non-standard PATH, set the PYTHON enviroment varirable to it"
        echo
        exit 1
    fi
}

function run_python_wth_env() {
    set_env
    check_python_executable
  
    $PYTHON ${*:2}
}


function check_process(){
    # check the args
    if [ "$1" = "" ];
    then
        return 0
    fi

    #PROCESS_NUM => get the process number regarding the given thread name
    PROCESS_NUM=$(ps -ef | grep "$1" | grep -v "grep" | wc -l)
    if [ $PROCESS_NUM -ge 1 ];
    then
    	return 1
    else
        echo "$1 already exit"
        exit 1
    fi
}

function migrate_source() {
    dirs=(
        include
        lib
        share
        bin
    )
    for d in ${dirs[*]}; do
        if [[ -e ${source_prefix}/$d ]]; then
            cp -rf ${source_prefix}/$d/* /usr/$d/
        fi
    done
}

case $1 in
    "start" )
        start_server
        ;;
    "python-env" )
        run_python_wth_env "$@"
        ;;
    "migrate" )
        migrate_source
        ;;
    * )
        start_server
        ;;
esac
