#!/bin/bash
set -e

PROJECT=$1


if [[ -z $PROJECT ]]; then
    echo 'please type command like: seafile-make.sh Project_name'
    exit 1
fi

if [[ ! -e ~/seafile/dev/${PROJECT} ]]; then
    echo "the project ${PROJECT} does not exists"
    exit 1
fi

cd ~/seafile/dev/${PROJECT}

if [ ! -z "$(git status --porcelain)" ]; then
    echo 'Working directory not clean'
    exit 0
fi


if [[ ${PROJECT} =~ ^.*?ccnet.*?$ || ${PROJECT} =~ ^.*?seafile.*?$ ]]; then
    ./configure --prefix=${SOURCE_PATH} && make && make install
    . ~/seafile/dev/run.sh migrate
    echo "$PROJECT has been compiled"
else
    echo "$PROJECT no compilation required"
fi
