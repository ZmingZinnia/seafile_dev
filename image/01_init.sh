#!/bin/bash

set -e

function local_make() {
    dirs=(
        include
        lib
        share
    )
    for d in ${dirs[*]}; do
        if [[ -e /root/seafile/make/$d ]]; then
            cp -rf /root/seafile/make/$d/* /usr/local/$d/
        fi
    done
    if [[ -e /root/seafile/make/bin ]]; then
        cp -rf /root/seafile/make/bin/* /usr/bin/
    fi
}

function link_seahub_setting() {
    rm -rf /root/seafile/dev/seahub/seahub/settings.py
    rm -rf /root/seafile/dev/seahub/seahub/local_settings.py
    ln -sf /data/conf/seahub_settings.py /root/seafile/dev/seahub/seahub/settings.py
    ln -sf /data/conf/local_settings.py /root/seafile/dev/seahub/seahub/local_settings.py
}


function prepare() {
    mkdir -p /data/dev
    rm -rf /root/seafile && ln -sf /data /root/seafile

    dirs=(
        make
        logs
    )
    for d in ${dirs[*]}; do
        if [[ ! -e /data/$d ]]; then
            mkdir -p /data/$d
        fi
    done

}

function init() {

    prepare

    cd /root/seafile/dev
    
    wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz && tar xf libmemcached-1.0.18.tar.gz && cd libmemcached-1.0.18/ && ./configure --prefix=/root/seafile/make && make && make install && ldconfig && cd ..

    local_make
    
    git clone https://github.com/haiwen/seafobj.git
    
    git clone https://github.com/haiwen/libevhtp.git && cd libevhtp/ && cmake -DCMAKE_INSTALL_PREFIX:PATH=/root/seafile/make -DEVHTP_DISABLE_SSL=OFF -DEVHTP_BUILD_SHARED=ON . && make && make install && ldconfig && cd ..

    local_make

    git clone https://github.com/haiwen/libsearpc.git && cd libsearpc && ./autogen.sh && ./configure --prefix=/root/seafile/make && make && make install && ldconfig && cd ..

    local_make

    ssh-keygen -F github.com || ssh-keyscan github.com >>~/.ssh/known_hosts

    git clone https://github.com/seafileltd/portable-python-libevent.git
    
    git clone git@github.com:seafileltd/ccnet-pro-server.git && cd ccnet-pro-server && git fetch origin 6.3-pro:6.3-pro && git checkout 6.3-pro && ./autogen.sh && ./configure --prefix=/root/seafile/make && make && make install && ldconfig && cd ..

    local_make

    ccnet-init -c /root/seafile/conf -n zming -H 127.0.0.1
    
    git clone git@github.com:seafileltd/seafile-pro-server.git && cd seafile-pro-server && git fetch origin 6.3-pro:6.3-pro && git checkout 6.3-pro && ./autogen.sh && ./configure --disable-fuse --prefix=/root/seafile/make && make && make install && ldconfig && cd ..

    local_make

    cd /root/seafile/conf && seaf-server-init -d seafile-data/ && echo "/root/seafile/conf/seafile-data" > seafile.ini && cd ..

    cd conf && sed "/13419/a[Database]\nENGINE = mysql\nHOST = db\nPORT = 3306\nUSER = root\nPASSWD = \nDB = ccnet\nCONNECTION_CHARSET = utf8" ccnet.conf && sed "/8082/a[database]\ntype = mysql\nhost = db\nport = 3306\nuser = root\npassword = /\ndb_name = seafile\nconnection_charset = utf8" seafile-data/seafile.conf

    cd /root/seafile/dev && git clone https://github.com/haiwen/seahub.git && cd seahub && git fetch origin 6.2:6.2 && git checkout 6.2 && pip install -r requirements.txt && pip install -r test-requirements.txt 

    cd /root/seafile/dev &&  cp /root/scripts/setenv.sh /root/seafile/dev/setenv.sh && cp /root/scripts/run-seahub.sh /root/seafile/dev/run-seahub.sh && . setenv.sh && cd seahub && python manage.py migrate

    cd /root/seafile/dev/seahub/seahub && cp settings.py /root/seafile/conf/seahub_settings.py && cd /root/seafile/conf && cat > local_settings.py <<EOF
DEBUG = True
TEMPLATE_DEBUG = True

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql', # Add 'postgresql_psycopg2', 'mysql', 'sqlite3' or 'oracle'.
        'NAME': 'seahub', # Or path to database file if using sqlite3.
        'USER': 'root',                      # Not used with sqlite3.
        'PASSWORD': '',                  # Not used with sqlite3.
        'HOST': 'db',                      # Set to empty string for localhost. Not used with sqlite3.
        'PORT': '3306',                      # Set to empty string for default. Not used with sqlite3.
    }
}
EOF

    cd /root/seafile/dev &&  git clone git@github.com:seafileltd/seahub-extra.git && cd seahub-extra && git fetch origin 6.2:6.2 && git checkout 6.2

    cd /root/seafile/dev && git clone git@github.com:seafileltd/seafevents.git && git fetch origin 6.2:6.2 && git checkout 6.2

    cd /root/seafile/conf && cat > seafevents.conf  <<EOF
[DATABASE]
type=mysql
username=root
password=
name=seafevents
host=db

[INDEX FILES]
enabled=true
interval=5m
seafesdir=/root/seafile/dev/seafes/

[STATISTICS]
enabled = true
EOF

    cd /root/seafile/dev && git clone git@github.com:seafileltd/seafes.git
}


if [[ ! -e /data ]]; then
    exit 1
fi


if [[ ! -e /data/dev ]]; then
    init
    cp /root/scripts/setenv.sh /root/seafile/dev
    cp /root/scripts/run-seahub.sh /root/seafile/dev
    chmod u+x /root/seafile/dev/*.sh
else
    rm -rf /root/seafile && ln -sf /data /root/seafile
fi

link_seahub_setting

local_make
