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

# build-in office

RUN apt-get install -qq -y cmake gcc libgetopt++-dev git 
RUN apt-get install -qq -y pkg-config libopenjpeg-dev libfontconfig1-dev libfontforge-dev poppler-data poppler-utils 
RUN apt-get install -qq -y packaging-dev pkg-config python-dev libpango1.0-dev libglib2.0-dev libxml2-dev
RUN apt-get install -qq -y libjpeg-dev libtiff-dev uthash-dev libspiro-dev libreoffice libreoffice-script-provider-python
RUN apt-get remove giflib-tools libgif-dev -y
RUN apt-get autoremove -y

RUN . /root/scripts/pip_install.sh

CMD ["/sbin/my_init", "--", "/data/dev/run.sh"]
