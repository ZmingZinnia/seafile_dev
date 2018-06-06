FROM phusion/baseimage:0.10.1

ENV UPDATE_AT=20160515 BRANCH=6.2

CMD ["/sbin/my_init", "--", "bash", "-l"]
RUN rm -rf /etc/my_init.d/*
COPY id_rsa.pub id_rsa /root/.ssh/
COPY 01_init.sh /etc/my_init.d/
COPY scripts /root/scripts

RUN apt-get update -qq && apt-get install python2.7 python-dev autoconf automake mysql-client -q=2
RUN rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

RUN apt-get install -y ssh libevent-dev libcurl4-openssl-dev libglib2.0-dev uuid-dev intltool libsqlite3-dev libmysqlclient-dev libarchive-dev libtool libjansson-dev valac libfuse-dev python-dateutil cmake re2c flex sqlite3 python-pip python-simplejson git libssl-dev libldap2-dev libonig-dev memcached

RUN apt install -y ssh libevent-dev libcurl4-openssl-dev libglib2.0-dev uuid-dev intltool libsqlite3-dev libmysqlclient-dev libarchive-dev libtool libjansson-dev valac libfuse-dev python-dateutil cmake re2c flex sqlite3 python-pip python-simplejson git libssl-dev libldap2-dev libonig-dev vim vim-scripts vim-gtk vim-gnome exuberant-ctags nodejs npm  wget

RUN . /root/scripts/pip_install.sh

CMD ["/sbin/my_init", "--", "/data/dev/run-seahub.sh"]
