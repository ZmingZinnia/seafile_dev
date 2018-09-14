FROM phusion/baseimage:0.10.1

ENV UPDATE_AT=20180913 BRANCH=master COMPILE_PATH=/data/compiled SOURCE_PATH=/data/dev LOG_PATH=/data/logs CONF_PATH=/data/conf

RUN rm -rf /etc/my_init.d/* /etc/apt/sources.list
COPY scripts/01_init.sh scripts/02_aliass.sh /etc/my_init.d/
COPY scripts/my-ubuntu-source.list /etc/apt/sources.list.d
COPY scripts /root/scripts

# npm for front-end dev
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN apt-get update -qq && apt-get install -y -qq python2.7 python-dev autoconf automake mysql-client
RUN rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


# See https://manual.seafile.com/develop/env.html
RUN apt-get install -y -qq ssh libevent-dev libcurl4-openssl-dev libglib2.0-dev \
  uuid-dev intltool libsqlite3-dev libmysqlclient-dev libarchive-dev libtool \
  libjansson-dev valac libfuse-dev python-dateutil cmake re2c flex sqlite3 python-pip \
  python-simplejson git libssl-dev libldap2-dev libonig-dev


# development tools
RUN apt-get install -qq -y vim vim-scripts wget nodejs git
RUN apt-get install -qq -y cmake gcc

# build-in office and file search
RUN apt-get install -qq -y pkg-config poppler-utils
# RUN apt-get install -qq -y libreoffice libreoffice-script-provider-python
# RUN apt-get install -qq -y ttf-wqy-microhei ttf-wqy-zenhei xfonts-wqy


RUN apt-get autoremove -y

RUN . /root/scripts/pip_install.sh

CMD ["/sbin/my_init", "--", "/root/scripts/enterpoint.sh"]
