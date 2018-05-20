#!/bin/bash
set -e

function init() {
    mkdir -p /data/dev
    ln -sf /data/dev /root/dev
    cd /root/dev
    
    wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz && tar xf libmemcached-1.0.18.tar.gz && cd libmemcached-1.0.18/ && ./configure && make && make install && ldconfig && cd ..
    
    git clone https://github.com/haiwen/seafobj.git
    
    git clone https://github.com/haiwen/libevhtp.git && cd libevhtp/ && cmake -DEVHTP_DISABLE_SSL=OFF -DEVHTP_BUILD_SHARED=ON . && make && make install && ldconfig && cd ..
    
    git clone https://github.com/haiwen/libsearpc.git && cd libsearpc && ./autogen.sh && ./configure && make && make install && ldconfig && cd ..

    ssh-keygen -F github.com || ssh-keyscan github.com >>~/.ssh/known_hosts

    git clone https://github.com/seafileltd/portable-python-libevent.git
    
    git clone git@github.com:seafileltd/ccnet-pro-server.git && cd ccnet-pro-server && git fetch origin 6.3-pro:6.3-pro && git checkout 6.3-pro && ./autogen.sh && ./configure && make && make install && ldconfig && cd ..

    ccnet-init -c /root/dev/conf -n zming -H 127.0.0.1
    
    git clone git@github.com:seafileltd/seafile-pro-server.git && cd seafile-pro-server && git fetch origin 6.3-pro:6.3-pro && git checkout 6.3-pro && ./autogen.sh && ./configure --disable-fuse && make && make install && ldconfig && cd ..

    cd conf && seaf-server-init -d seafile-data/ && echo "/root/dev/conf/seafile-data" > seafile.ini && cd ..

    mysql -u root -p123 -e "create database seahub charset utf8;"
    
    git clone https://github.com/haiwen/seahub.git && cd seahub && git fetch origin 6.2:6.2 && git checkout 6.2 && pip install -r requirements.txt && pip install -r test-requirements.txt 

    cd /root/dev &&  cp /root/setenv.sh /root/dev/setenv.sh && cp /root/run-seahub.sh /root/dev/run-seahub.sh && . setenv.sh && cd seahub && python manage.py migrate

    cd /root/dev/seahub/seahub && cat > local_settings.py <<EOF
DEBUG = True
TEMPLATE_DEBUG = True

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql', # Add 'postgresql_psycopg2', 'mysql', 'sqlite3' or 'oracle'.
        'NAME': 'seahub', # Or path to database file if using sqlite3.
        'USER': 'root',                      # Not used with sqlite3.
        'PASSWORD': '123',                  # Not used with sqlite3.
        'HOST': 'localhost',                      # Set to empty string for localhost. Not used with sqlite3.
        'PORT': '3306',                      # Set to empty string for default. Not used with sqlite3.
    }
}
EOF

    cd /root/dev &&  git clone git@github.com:seafileltd/seahub-extra.git && cd seahub-extra && git fetch origin 6.2:6.2 && git checkout 6.2

    mysql -u root -p123 -e "create database seafevents charset utf8;"

    cd /root/dev && git clone git@github.com:seafileltd/seafevents.git && git fetch origin 6.2:6.2 && git checkout 6.2

    cd seafevents && cat > events.conf  <<EOF
[DATABASE]
type=mysql
username=root
password=
name=seafevents
host=localhost

[INDEX FILES]
enabled=true
interval=5m
seafesdir=/root/dev/seafes/

[STATISTICS]
enabled = true
EOF

    cd /root/dev && git clone git@github.com:seafileltd/seafes.git
}

service mysql start
mysqladmin -uroot password ''

if [[ -e /data/dev ]]; then
    rm -rf /root/dev && ln -sf /data/dev /root/dev
else
    init
    cp /root/setenv.sh /root/dev
    cp /root/run-seahub.sh /root/dev
    chmod u+x /root/dev/*.sh
fi


