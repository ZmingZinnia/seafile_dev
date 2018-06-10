#!/bin/bash

set -e

source_prefix=/root/seafile/migrate/source
office_dep_path=/root/seafile/dev/office_dep

function local_migrate() {
    dirs=(
        include
        lib
        bin
        share
    )
    for d in ${dirs[*]}; do
        if [[ -e ${source_prefix}/$d ]]; then
            cp -rf ${source_prefix}/$d/* /usr/$d/
        fi
    done
}

function link_seahub_setting() {
    rm -rf /root/seafile/dev/seahub/seahub/settings.py
    rm -rf /root/seafile/dev/seahub/seahub/local_settings.py
    ln -sf /data/conf/seahub_settings.py /root/seafile/dev/seahub/seahub/settings.py
    ln -sf /data/conf/local_settings.py /root/seafile/dev/seahub/seahub/local_settings.py
}

function prepare_init() {
    mkdir -p /data/dev
    rm -rf /root/seafile && ln -sf /data /root/seafile

    dirs=(
        migrate/source
        logs
    )
    for d in ${dirs[*]}; do
        if [[ ! -e /data/$d ]]; then
            mkdir -p /data/$d
        fi
    done
}


function init() {

    prepare_init

    cd /root/seafile/dev
    
    wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz && tar xf libmemcached-1.0.18.tar.gz && cd libmemcached-1.0.18/ && ./configure --prefix=$source_prefix && make && make install && ldconfig && cd ..

    local_migrate
    
    git clone https://github.com/haiwen/seafobj.git
    
    git clone https://github.com/haiwen/libevhtp.git && cd libevhtp/ && cmake -DCMAKE_INSTALL_PREFIX:PATH=$source_prefix -DEVHTP_DISABLE_SSL=OFF -DEVHTP_BUILD_SHARED=ON . && make && make install && ldconfig && cd ..

    local_migrate

    git clone https://github.com/haiwen/libsearpc.git && cd libsearpc && ./autogen.sh && ./configure --prefix=$source_prefix && make && make install && ldconfig && cd ..

    local_migrate

    ssh-keygen -F github.com || ssh-keyscan github.com >>~/.ssh/known_hosts

    git clone https://github.com/seafileltd/portable-python-libevent.git
    
    git clone git@github.com:seafileltd/ccnet-pro-server.git && cd ccnet-pro-server && git fetch origin 6.3-pro:6.3-pro && git checkout 6.3-pro && ./autogen.sh && ./configure --prefix=$source_prefix && make && make install && ldconfig && cd ..

    local_migrate

    ccnet-init -c /root/seafile/conf -n zming -H 127.0.0.1
    
    git clone git@github.com:seafileltd/seafile-pro-server.git && cd seafile-pro-server && git fetch origin 6.3-pro:6.3-pro && git checkout 6.3-pro && ./autogen.sh && ./configure --disable-fuse --prefix=$source_prefix && make && make install && ldconfig && cd ..

    local_migrate

    cd /root/seafile/conf && seaf-server-init -d seafile-data/ && echo "/root/seafile/conf/seafile-data" > seafile.ini && cd ..

    cd conf && echo -en "\n[Database]\nENGINE = mysql\nHOST = db\nPORT = 3306\nUSER = root\nPASSWD = db_dev\nDB = ccnet\nCONNECTION_CHARSET = utf8" >> ccnet.conf && echo -en "\n[database]\ntype = mysql\nhost = db\nport = 3306\nuser = root\npassword = db_dev\ndb_name = seafile\nconnection_charset = utf8" >> seafile-data/seafile.conf

    cd /root/seafile/dev && git clone https://github.com/haiwen/seahub.git && cd seahub && git fetch origin 6.3:6.3 && git checkout 6.3

    cd /root/seafile/dev/seahub/seahub && cp settings.py /root/seafile/conf/seahub_settings.py && cd /root/seafile/conf && cat > local_settings.py <<EOF
DEBUG = True
TEMPLATE_DEBUG = True

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql', # Add 'postgresql_psycopg2', 'mysql', 'sqlite3' or 'oracle'.
        'NAME': 'seahub', # Or path to database file if using sqlite3.
        'USER': 'root',                      # Not used with sqlite3.
        'PASSWORD': 'db_dev',                  # Not used with sqlite3.
        'HOST': 'db',                      # Set to empty string for localhost. Not used with sqlite3.
        'PORT': '3306',                      # Set to empty string for default. Not used with sqlite3.
    }
}
EOF

    cd /root/seafile/dev &&  git clone git@github.com:seafileltd/seahub-extra.git && cd seahub-extra && git fetch origin 6.3:6.3 && git checkout 6.3

    cd /root/seafile/dev && git clone git@github.com:seafileltd/seafevents.git && cd seafevents && git fetch origin 6.3:6.3 && git checkout 6.3

    cd /root/seafile/conf && cat > seafevents.conf  <<EOF
[DATABASE]
type=mysql
username=root
password=db_dev
name=seafevents
host=db

[INDEX FILES]
enabled=true
interval=5m
seafesdir=/root/seafile/dev/seafes/

[STATISTICS]
enabled = true

[OFFICE CONVERTER]
enabled = true
EOF

    cd /root/seafile/dev && git clone git@github.com:seafileltd/seafes.git

    # build-in office
    #mkdir -p  $office_dep_path
    #cd $office_dep_path && git clone https://github.com/fontforge/libspiro.git && cd libspiro && autoreconf -i && automake --foreign -Wall && ./configure --prefix=$source_prefix && make && make check && make install

    #local_migrate

    #cd $office_dep_path && git clone https://github.com/LuaDist/libjpeg.git && cd libjpeg && ./configure --prefix=$source_prefix && make && make install

    #local_migrate

    #cd $office_dep_path && git clone https://github.com/glennrp/libpng.git && cd libpng && git reset --soft af08094ba669eb22401fe1bd771d12a866a6b24e && git reset --hard && ./autogen.sh && ./configure --prefix=$source_prefix && make && make install

    #local_migrate

    #cd $office_dep_path && wget https://ftp.osuosl.org/pub/blfs/conglomeration/poppler/poppler-data-0.4.7.tar.gz && tar -zxvf poppler-data-0.4.7.tar.gz && cd poppler-data-0.4.7 && make install datadir=/usr DESTDIR=/tmp/buildroot-xyz2000

    #local_migrate

    #cd $office_dep_path && wget https://poppler.freedesktop.org/poppler-0.44.0.tar.xz && tar -xvf poppler-0.44.0.tar.xz && cd poppler-0.44.0/ && ./configure --enable-xpdf-headers --prefix=$source_prefix && make && make install

    #local_migrate

    #cd $office_dep_path && git clone --depth 1 https://github.com/coolwanglu/fontforge.git && cd fontforge && git fetch origin pdf2htmlEX:pdf2htmlEX && git checkout pdf2htmlEX && ./autogen.sh && ./configure --prefix=$source_prefix && make && make install

    #local_migrate

    #cd $office_dep_path && git clone --depth 1 https://github.com/coolwanglu/pdf2htmlEX.git && cd pdf2htmlEX/ && cmake -DCMAKE_INSTALL_PREFIX:PATH=$source_prefix . && make && make install

    #local_migrate
}


if [[ ! -e /data ]]; then
    exit 1
fi

if [[ ! -e /data/ssh_key/id_rsa.pub || ! -e /data/ssh_key/id_rsa ]]; then
    echo 'do not find ssh private/public key, exit'
    exit 1
fi

cp -rf /data/ssh_key/id_rsa.pub /data/ssh_key/id_rsa /root/.ssh/

if [[ ! -e /data/dev ]]; then
    init
    cp /root/scripts/run.sh /root/seafile/dev
    chmod u+x /root/seafile/dev/*.sh
else
    rm -rf /root/seafile && ln -sf /data /root/seafile
fi

link_seahub_setting

local_migrate
