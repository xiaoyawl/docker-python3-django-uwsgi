#!/bin/bash
#########################################################################
# File Name: etc/pyenv-setup.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: 2019年06月02日 星期日 23时07分50秒
#########################################################################


#Install Python
apk --update --no-cache upgrade && apk add --no-cache --virtual .build-deps xz build-base zlib-dev libffi-dev readline-dev sqlite-dev openssl-dev bzip2-dev pcre-dev libuuid
runDeps="$( scanelf --needed --nobanner --recursive /usr/local/ | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u | xargs -r apk info --installed | sort -u )"
runDeps="${runDeps} zlib-dev libffi-dev readline-dev sqlite-dev openssl-dev bzip2-dev pcre-dev libuuid tzdata"

export PYENV_ROOT="/root/.pyenv" && \
export PATH="$PYENV_ROOT/bin:$PATH" && \
export CFLAGS='-O2' && \
eval "$(pyenv init -)" && \
pyenv install $1 && \
pyenv global $1 && \
pip install --upgrade pip && \
pyenv rehash

apk del .build-deps build-base xz
apk add --no-cache --virtual .py3-rundeps $runDeps
rm -rf /var/cache/apk/* 
