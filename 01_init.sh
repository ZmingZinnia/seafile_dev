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
    
    git clone git@github.com:seafileltd/ccnet-pro-server.git && cd ccnet-pro-server && ./autogen.sh && ./configure && make && make install && ldconfig && cd ..

    ccnet-init -c /root/dev/conf -n zming -H 127.0.0.1
    
    git clone git@github.com:seafileltd/seafile-pro-server.git && cd seafile-pro-server && ./autogen.sh && ./configure --disable-fuse && make && make install && ldconfig && cd ..

    cd conf && seaf-server-init -d seafile-data/ && echo "/root/dev/conf/seafile-data" > seafile.ini && cd ..
    
    git clone https://github.com/haiwen/seahub.git && cd seahub && pip install -r requirements.txt && pip install -r test-requirements.txt && cd ..
}


if [[ -e /data/dev ]]; then
    rm -rf /root/dev && ln -sf /data/dev /root/dev
else
    init
fi
