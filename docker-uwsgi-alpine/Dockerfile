FROM benyoo/alpine:3.9.20190527
MAINTAINER from www.dwhd.org by lookback (mondeolove@gmail.com)

ARG VERSION_NGINX=${VERSION_NGINX:-1.16.0}
ARG VERSION_Django=${VERSION_Django:-2.1.4}
#ARG SHA256=${SHA256:-1045ac4987a396e2fa5d0011daf8987b612dd2f05181b67507da68cbe7d765c2}
ARG AUTOINDEX_NAME_LEN=${AUTOINDEX_NAME_LEN:-100}
ARG BUILD_DATE=${BUILD_DATE:-"$(date +'%Y-%m-%d %H-%M-%S')"}
ARG VCS_REF

ENV LANG C.UTF-8
ENV INSTALL_DIR=/usr/local/nginx \
	DATA_DIR=/data/wwwroot \
	TEMP_DIR=/tmp/nginx


RUN set -x && \
	mkdir -p $(dirname ${DATA_DIR}) ${TEMP_DIR} && \
	apk --update --no-cache upgrade && \
	apk add --no-cache --virtual .build-deps geoip geoip-dev pcre libxslt gd openssl-dev pcre-dev zlib-dev \
		build-base linux-headers libxslt-dev gd-dev openssl-dev libstdc++ libgcc patch git tar curl luajit-dev=2.1.0_beta3-r4 && \
	cd ${TEMP_DIR} && \
	DOWN_URL="http://nginx.org/download" && \
	DOWN_URL="${DOWN_URL}/nginx-${VERSION_NGINX}.tar.gz" && \
	FILE_NAME=${DOWN_URL##*/} && mkdir -p ${TEMP_DIR}/${FILE_NAME%%\.tar*} && \
	curl -Lk ${DOWN_URL} | tar xz -C ${TEMP_DIR} --strip-components=1 && \
	git clone -b v0.6.4 https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git && \
	git clone -b v0.4.3 https://github.com/aperezdc/ngx-fancyindex.git && \
	git clone -b v0.3.1rc1 https://github.com/simplresty/ngx_devel_kit.git && \
	git clone -b v0.10.13 https://github.com/openresty/lua-nginx-module.git && \
	git clone -b v0.1.18 https://github.com/vozlt/nginx-module-vts.git && \
	git clone -b v0.3.0 https://github.com/yaoweibin/nginx_upstream_check_module.git && \
	git clone https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng.git && \
	git clone https://github.com/yzprofile/ngx_http_dyups_module.git && \
	git clone https://github.com/cfsego/ngx_log_if.git && \
	git clone https://github.com/openresty/headers-more-nginx-module.git && \
	git clone https://github.com/ipipdotnet/nginx-ipip-module.git && \
	addgroup -g 400 -S www && \
	adduser -u 400 -S -h ${DATA_DIR} -s /bin/bash -g 'WEB Server' -G www www && \
	export LUAJIT_LIB=/usr/lib && \
	export LUAJIT_INC=/usr/include/luajit-2.1 && \
	CFLAGS=-Wno-unused-but-set-variable ./configure --prefix=${INSTALL_DIR} \
		--user=www --group=www \
		--error-log-path=/data/wwwlogs/error.log \
		--http-log-path=/data/wwwlogs/access.log \
		--pid-path=/usr/local/nginx/nginx.pid \
		--lock-path=/var/lock/nginx.lock \
		--with-pcre \
		--with-ipv6 \
		--with-mail \
		--with-mail_ssl_module \
		--with-pcre-jit \
		--with-file-aio \
		--with-compat \
		--with-threads \
		--with-stream \
		--with-stream_ssl_module \
		--with-http_ssl_module \
		--with-http_flv_module \
		--with-http_v2_module \
		--with-http_realip_module \
		--with-http_gzip_static_module \
		--with-http_stub_status_module \
		--with-http_sub_module \
		--with-http_mp4_module \
		--with-http_image_filter_module \
		--with-http_addition_module \
		--with-http_auth_request_module \
		--with-http_dav_module \
		--with-http_degradation_module \
		--with-http_geoip_module \
		--with-http_xslt_module \
		--with-http_gunzip_module \
		--with-http_secure_link_module \
		--with-http_slice_module \
		--add-module=./ngx-fancyindex \
		--add-module=./ngx_http_substitutions_filter_module \
		--add-module=./ngx_devel_kit \
		--add-module=./lua-nginx-module \
		--add-module=./nginx-module-vts \
		--add-module=./nginx_upstream_check_module \
		--add-module=./ngx_log_if \
		--add-module=./ngx_http_dyups_module \
		--add-module=./headers-more-nginx-module \
		--add-dynamic-module=./nginx-ipip-module \
	&& \
	make -j$(getconf _NPROCESSORS_ONLN) && \
	make install && \
	echo -e "\n\nBulid done\n\n" && \
	runDeps="$( scanelf --needed --nobanner --recursive /usr/local/ | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u | xargs -r apk info --installed | sort -u )" && \
	#runDeps="${runDeps} inotify-tools supervisor logrotate python luajit-dev=2.1.0_beta3-r4" && \
	runDeps="${runDeps} inotify-tools logrotate luajit-dev=2.1.0_beta3-r4" && \
	#apk del .build-deps build-base git patch && \
	apk add --no-cache --virtual .ngx-rundeps $runDeps && \
	rm -rf /var/cache/apk/* /tmp/* ${INSTALL_DIR}/conf/nginx.conf

#Install Python3.7
RUN set -x && \
	apk --update --no-cache upgrade && apk add --no-cache --virtual .py-build-deps xz build-base zlib-dev libffi-dev readline-dev sqlite-dev openssl-dev bzip2-dev pcre-dev libuuid && \
	mkdir -p /tmp/python3 && \
	curl -Lks https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz|tar xJ -C /tmp/python3 --strip-components=1 && \
	cd /tmp/python3 && \
	./configure && make -j$(getconf _NPROCESSORS_ONLN) && make install && \
	runDeps="$( scanelf --needed --nobanner --recursive /usr/local/ | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u | xargs -r apk info --installed | sort -u )" && \
	runDeps="${runDeps} zlib-dev libffi-dev readline-dev sqlite-dev openssl-dev bzip2-dev pcre-dev libuuid tzdata" && \
	#apk del .py-build-deps build-base xz && \
	apk add --no-cache --virtual .py3-rundeps $runDeps && \
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
	rm -rf /var/cache/apk/* /tmp/*

#Install py package
RUN set -x && \
	{ [ ! -f /usr/bin/python ] && ln -sv /usr/local/bin/python3 /usr/bin/python; } && \
	{ [ ! -f /usr/bin/pip ] && ln -sv /usr/local/bin/pip3 /usr/bin/pip; } && \
	pip3 install --upgrade pip setuptools supervisor uwsgi && \
	pip install amqp==1.4.9 anyjson==0.3.3 asn1crypto==0.24.0 bcrypt==3.1.6 \
        billiard==3.3.0.23 certifi==2018.11.29 cffi==1.12.2 chardet==3.0.4 cryptography==2.6.1 \
        Django==2.1.4 django-background-tasks==1.2.0 django-compat==1.0.15 dnspython==1.16.0 \
        future==0.17.1 idna==2.8 kombu==3.0.37 pexpect==4.7.0 ptyprocess==0.6.0 pyasn1==0.4.5 \
        pycparser==2.19 PyMySQL==0.9.3 PyNaCl==1.3.0 python-telegram-bot==11.1.0 pytz==2018.7 \
        requests==2.21.0 six==1.12.0 SQLAlchemy==1.2.15 telegram==0.0.1 tzlocal==1.5.1 \
        urllib3==1.24.1 vine==1.3.0

ADD etc /etc
#ADD .pyenv /root/.pyenv

ENV PATH=${INSTALL_DIR}/sbin:$PATH \
	TERM=linux

RUN set -x && \
	mv /etc/entrypoint.sh entrypoint.sh && \
	chmod +x /entrypoint.sh /etc/pyenv-setup.sh

VOLUME ["${DATA_DIR}"]
EXPOSE 80 443

LABEL \
    maintainer="mondeolove@gmail.com" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name=uwsgi \
    org.label-schema.vendor=damagehead \
    org.label-schema.url="https://github.com/xiaoyawl/docker-uwsgi" \
    org.label-schema.vcs-url="https://github.com/xiaoyawl/docker-uwsgi.git" \
    org.label-schema.vcs-ref=${VCS_REF} \
    com.damagehead.gitlab.license=MIT

ENTRYPOINT ["/entrypoint.sh"]
