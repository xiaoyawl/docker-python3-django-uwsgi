FROM benyoo/centos:7.6.1810.20190603
MAINTAINER from www.dwhd.org by lookback (mondeolove@gmail.com)

ARG VERSION_NGINX=${VERSION_NGINX:-1.16.0}
ARG VERSION_Django=${VERSION_Django:-2.1.4}
ARG VERSION_Python3=${VERSION_Python3:-3.7.3}
#ARG SHA256=${SHA256:-1045ac4987a396e2fa5d0011daf8987b612dd2f05181b67507da68cbe7d765c2}
ARG AUTOINDEX_NAME_LEN=${AUTOINDEX_NAME_LEN:-100}
ARG BUILD_DATE=${BUILD_DATE:-"$(date +'%Y-%m-%d %H-%M-%S')"}
ARG VCS_REF

#ENV LANG C.UTF-8
ENV NGINX_INSTALL_DIR=/usr/local/nginx \
    PYTHON3_INSTALL_DIR=/usr/local/python3 \
    DATA_DIR=/data/wwwroot \
    TEMP_DIR_Nginx=/tmp/nginx\
    TEMP_DIR_Python=/tmp/python

#Install Python3 and Operating environment
RUN set -x && \
	yum install -y epel-release gcc gcc-c++ make zlib-devel readline-devel sqlite-devel openssl-devel libffi-devel && \
	yum reinstall -y glibc-common && \
	echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf && \
	mkdir -p $TEMP_DIR_Python && cd $TEMP_DIR_Python && \
	URL=https://www.python.org/ftp/python && \
	curl -Lks "${URL}"/$(curl -Lks "${URL}"|awk -F'[/"]' '$2~/^'"$VERSION_Python3"'/{a=$2}END{print a}')/$(curl -Lks "${URL}"/$(curl -Lks "${URL}" | awk -F'[/"]' '$2~/^'"$VERSION_Python3"'/{a=$2}END{print a}') | awk -F'[><]' '$3~/tar.xz$/{print $3}')|tar -xJ -C ${TEMP_DIR_Python} --strip-components=1 && \
	./configure --prefix=${PYTHON3_INSTALL_DIR} && \
	make -j$(getconf _NPROCESSORS_ONLN) && \
	make install && \
	echo 'export PATH=/usr/local/python3/bin:$PATH' > /etc/profile.d/python3.sh && \
	curl https://bootstrap.pypa.io/get-pip.py | ${PYTHON3_INSTALL_DIR}/bin/python3 && \
	${PYTHON3_INSTALL_DIR}/bin/pip3 install --upgrade pip setuptools supervisor uwsgi && \
	${PYTHON3_INSTALL_DIR}/bin/pip3 install amqp==1.4.9 anyjson==0.3.3 asn1crypto==0.24.0 bcrypt==3.1.6 \
		billiard==3.3.0.23 certifi==2018.11.29 cffi==1.12.2 chardet==3.0.4 cryptography==2.6.1 \
		Django==2.1.4 django-background-tasks==1.2.0 django-compat==1.0.15 dnspython==1.16.0 \
		future==0.17.1 idna==2.8 kombu==3.0.37 pexpect==4.7.0 ptyprocess==0.6.0 pyasn1==0.4.5 \
		pycparser==2.19 PyMySQL==0.9.3 PyNaCl==1.3.0 python-telegram-bot==11.1.0 pytz==2018.7 \
		requests==2.21.0 six==1.12.0 SQLAlchemy==1.2.15 telegram==0.0.1 tzlocal==1.5.1 \
		urllib3==1.24.1 vine==1.3.0 && \
	sed -i '1s@.*@#!/usr/bin/python2.7.5@' /usr/bin/yum /usr/libexec/urlgrabber-ext-down && \
	mv /usr/bin/python /usr/bin/python2.7.5 && \
	ln -vs ${PYTHON3_INSTALL_DIR}/bin/python3.7  /usr/bin/python && \
	[ ! -f /usr/bin/pip ] && ln -sv /usr/local/python3/bin/pip3 /usr/bin/pip && \
	yum clean all && \
	cd - && rm -rf ${TEMP_DIR_Python}

#Install Nginx
RUN set -x && \
	mkdir -p $TEMP_DIR_Nginx && cd $TEMP_DIR_Nginx && \
	groupadd -g 400 www && \
	useradd -M -u 400 -g 400 -s /sbin/nologin www && \
	DOWN_URL="http://nginx.org/download" && \
	DOWN_URL="${DOWN_URL}/nginx-${VERSION_NGINX}.tar.gz" && \
	FILE_NAME=${DOWN_URL##*/} && mkdir -p ${TEMP_DIR}/${FILE_NAME%%\.tar*} && \
	curl -Lk ${DOWN_URL} | tar xz -C ${TEMP_DIR_Nginx} --strip-components=1 && \
	yum install -y lua-devel pcre-devel libxslt-devel libxml2-devel gd-devel perl-devel GeoIP-devel \
		git inotify-tools crontabs logrotate && \
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
	./configure --prefix=${NGINX_INSTALL_DIR} \
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
	echo 'export PATH=/usr/local/nginx/sbin:$PATH' > /etc/profile.d/nginx.sh && \
	echo -e "\n\nBulid done\n\n" && \
	yum clean all && \
	cd - && \rm -rf ${TEMP_DIR_Nginx}

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
