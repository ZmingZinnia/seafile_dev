#!/bin/bash

#set -e

function stop_server() {
    pkill -9 -f ccnet-server
    pkill -9 -f seaf-server
    pkill -9 -f runserver
    pkill -9 -f main
}

function set_env() {
    export CCNET_CONF_DIR=$CONF_PATH
    export SEAFILE_CONF_DIR=$CONF_PATH/seafile-data
    export PYTHONPATH=/usr/lib/python2.7/dist-packages:/usr/lib/python2.7/site-packages:/usr/local/lib/python2.7/dist-packages:/usr/local/lib/python2.7/site-packages:/data/dev/seahub/thirdpart:/data/dev/pyes/pyes:/data/dev/seahub-extra::/data/dev/portable-python-libevent/libevent:/data/dev/seafobj:/data/dev/:/data/dev/seahub/seahub/:$CONF_PATH:$PYTHONPATH
    export SEAFES_DIR=/data/dev/seafes/
}

function start_server() {
    stop_server

    set_env

    nohup ccnet-server -c $CONF_PATH -D all -L /data -f - > $LOG_PATH/ccnet.log 2>&1 &
    sleep 0.5
    nohup seaf-server -c $CONF_PATH -d $CONF_PATH/seafile-data -D all -f -l - > $LOG_PATH/seafile.log 2>&1 &
    sleep 0.5
    cd /data/dev/seahub
    nohup python manage.py runserver 0.0.0.0:8000 2>&1 > $LOG_PATH/seahub-runtime.log &
    cd ../seafevents
    sleep 0.5
    nohup python main.py --config-file $CONF_PATH/seafevents.conf 2>&1 > $LOG_PATH/seafevents.log &
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
        if [[ -e ${SOURCE_PATH}/$d ]]; then
            cp -rf ${SOURCE_PATH}/$d/* /usr/$d/
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
