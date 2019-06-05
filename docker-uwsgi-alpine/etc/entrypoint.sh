#!/bin/bash
#########################################################################
# File Name: entrypoint.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: 2016年08月12日 星期五 16时43分50秒
#########################################################################

set -e
[[ $DEBUG == true ]] && set -x
DEFAULT_CONF=${DEFAULT_CONF:-enable}

if [ -n "$TIMEZONE" ]; then
	rm -rf /etc/localtime && \
	ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
fi

Nginx_Conf_Dir=/etc/nginx-conf-example
[ ! -d /var/log/supervisor ] && mkdir -p /var/log/supervisor
#[ "${1:0:1}" = '-' ] && set -- nginx "$@"

mkdir -p ${DATA_DIR}
[ ! -f "$DATA_DIR/index.html" ] && echo 'Hello here, Let us see the world.' > $DATA_DIR/index.html

if [ -d /etc/logrotate.d ]; then
	cat > /etc/logrotate.d/nginx <<-EOF
    $(dirname ${DATA_DIR})/wwwlogs/*.log {
        daily
        rotate 5
        missingok
        dateext
        compress
        notifempty
        sharedscripts
        postrotate
        [ -e /var/run/nginx.pid ] && kill -USR1 \`cat /var/run/nginx.pid\`
        endscript
    }
EOF
fi

#if [ ! -f ${INSTALL_DIR}/conf/nginx.conf ]; then
if [[ "${DEFAULT_CONF}" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	chown -R www.www $DATA_DIR
	cat ${Nginx_Conf_Dir}/nginx.conf > ${INSTALL_DIR}/conf/nginx.conf
	sed -i "s@/home/wwwroot@$DATA_DIR@" ${INSTALL_DIR}/conf/nginx.conf
	if [[ "${PHP_FPM}" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
		Space1="        " && Space2="${Space1}    "
		sed -i "/location.*gif/i \\${Space1}location ~ .*\\\.(php|php5)?\$ {\n${Space2}fastcgi_pass PHP_FPM_SERVER:PORT;\n${Space2}#fastcgi_pass unix:/dev/shm/php-cgi.sock;\n${Space2}fastcgi_index index.php;\n${Space2}include fastcgi.conf;\n${Space1}}\n" ${INSTALL_DIR}/conf/nginx.conf
		if [ -z "${PHP_FPM_SERVER}" ]; then
			echo >&2 'error:  missing PHP_FPM_SERVER'
			echo >&2 '  Did you forget to add -e PHP_FPM_SERVER=... ?'
			exit 127
		fi
		PHP_FPM_PORT=${PHP_FPM_PORT:-9000}
		sed -i "s/PHP_FPM_SERVER/${PHP_FPM_SERVER}/" ${INSTALL_DIR}/conf/nginx.conf
		sed -i "s/PORT/${PHP_FPM_PORT}/" ${INSTALL_DIR}/conf/nginx.conf
		[ -f ${DATA_DIR}/index.php ] || cat > ${DATA_DIR}/index.php <<< '<? phpinfo(); ?>'
	fi
fi

if [[ "${IPIP}" =~ ^[eE][nN][aA][bB][lL][eE]$ ]]; then
	if ! ls ${INSTALL_DIR}/conf | grep -q ip_dabases; then
		mkdir -p ${INSTALL_DIR}/conf/ip_dabases
	fi
	if ! ls ${INSTALL_DIR}/conf/ip_dabases| grep -q 17monipdb.datx; then
		cp -a ${Nginx_Conf_Dir}/17monipdb.datx ${INSTALL_DIR}/conf/ip_dabases/
	fi
	if ! grep -q ipip_db ${INSTALL_DIR}/conf/nginx.conf; then
		sed -i "/log_format upstream2/i \    ipip_db ${INSTALL_DIR}/conf/ip_dabases/17monipdb.datx 60m; # 60 minute auto reload db file" ${INSTALL_DIR}/conf/nginx.conf
	fi
	if ! grep -q ipip_parse_ip ${INSTALL_DIR}/conf/nginx.conf; then
		sed -i "/log_format upstream2/i \    ipip_parse_ip \$http_x_forwarded_for;\n" ${INSTALL_DIR}/conf/nginx.conf
	fi
fi

if [ -n "${Server_Name}" ]; then
        sed -i "/server {/i \    more_set_headers 'Server: $Server_Name';\n" ${INSTALL_DIR}/conf/nginx.conf
fi

if [ -n "$REWRITE" ]; then
	[ ! -d ${INSTALL_DIR}/conf/rewrite ] && mkdir -p ${INSTALL_DIR}/conf/rewrite
	if [ "$REWRITE" = "wordpress" ]; then
	[ ! -f ${INSTALL_DIR}/conf/rewrite/wordpress.conf ] && cp ${Nginx_Conf_Dir}/rewrite/wordpress.conf ${INSTALL_DIR}/conf/rewrite/wordpress.conf
	elif [ "$REWRITE" = "discuz" ]; then
	[ ! -f ${INSTALL_DIR}/conf/rewrite/discuz.conf ] && cp ${Nginx_Conf_Dir}/rewrite/discuz.conf ${INSTALL_DIR}/conf/rewrite/discuz.conf
	elif [ "$REWRITE" = "opencart" ]; then
	[ ! -f ${INSTALL_DIR}/conf/rewrite/opencart.conf ] && cp ${Nginx_Conf_Dir}/rewrite/opencart.conf ${INSTALL_DIR}/conf/rewrite/opencart.conf
	elif [ "$REWRITE" = "laravel" ]; then
	[ ! -f ${INSTALL_DIR}/conf/rewrite/opencart.conf ] && cp ${Nginx_Conf_Dir}/rewrite/opencart.conf ${INSTALL_DIR}/conf/rewrite/opencart.conf
	elif [ ! -f "$REWRITE" = "typecho" ]; then
	[ ! -f ${INSTALL_DIR}/conf/rewrite/typecho.conf ] && cp ${Nginx_Conf_Dir}/rewrite/typecho.conf ${INSTALL_DIR}/conf/rewrite/typecho.conf
	elif [ ! -f "$REWRITE" = "ecshop" ]; then
	[ ! -f ${INSTALL_DIR}/conf/rewrite/ecshop.conf ] && cp ${Nginx_Conf_Dir}/rewrite/ecshop.conf ${INSTALL_DIR}/conf/rewrite/ecshop.conf
	elif [ ! -f "$REWRITE" = "drupal" ]; then
	[ ! -f ${INSTALL_DIR}/conf/rewrite/drupal.conf ] && cp ${Nginx_Conf_Dir}/rewrite/drupal.conf ${INSTALL_DIR}/conf/rewrite/drupal.conf
	elif [ ! -f "$REWRITE" = "joomla" ]; then
	[ ! -f ${INSTALL_DIR}/conf/rewrite/joomla.conf ] && cp ${Nginx_Conf_Dir}/rewrite/joomla.conf ${INSTALL_DIR}/conf/rewrite/joomla.conf
	fi
fi

#if [[ -n ${SUPERVISOR_PORT} ]]; then
#       sed -i "s/^port.*/port = 0.0.0.0:${SUPERVISOR_PORT}/" /etc/supervisord.conf
#fi

for i in `find /usr/local/nginx/conf -type f`;do sed -i 's/\r$//g' $i;done

DATE_TIME_ZONE=${DATE_TIME_ZONE:-Asia/Shanghai}
rm -rf /etc/localtime
ln -sv /usr/share/zoneinfo/${DATE_TIME_ZONE} /etc/localtime
#echo "$DATE_TIME_ZONE" >  /etc/timezone
#export TZ="$DATE_TIME_ZONE"

###SET uwsgi
PYTHON_VERSION=${PYTHON_VERSION:-3.7.2}
#/etc/pyenv-setup.sh $PYTHON_VERSION

SOCKET_PORT=${SOCKET_PORT:-8997}
SOCKET_IP=${SOCKET_IP:-0.0.0.0}
SOCKET_FILE=${SOCKET_FILE:-/tmp/uwsgi-socket.sock}
PY_AUTORELOAD=${PY_AUTORELOAD:-3}
UWSGI_MASTER=${UWSGI_MASTER:-True}
UWGSI_WORKERS=${UWGSI_WORKERS:-$(getconf _NPROCESSORS_ONLN)}
UWSGI_PID_FILE=${UWSGI_PID_FILE:-/tmp/uwsgi-master.pid}
UWSGI_MAX_REQUESTS=${UWSGI_MAX_REQUESTS:-5000}

sed -ri "2s@^(socket=).*@\1$SOCKET_IP:$SOCKET_PORT@"  /etc/uwsgi/uwsgi.ini
sed -ri "3s@^(socket=).*@\1$SOCKET_FILE@" /etc/uwsgi/uwsgi.ini
sed -ri "s@^(py-autoreload=).*@\1$PY_AUTORELOAD@" /etc/uwsgi/uwsgi.ini
sed -ri "s@^(master=).*@\1$UWSGI_MASTER@" /etc/uwsgi/uwsgi.ini
sed -ri "s@^(workers=).*@\1$UWGSI_WORKERS@" /etc/uwsgi/uwsgi.ini
sed -ri "s@^(pidfile=).*@\1$UWSGI_PID_FILE@" /etc/uwsgi/uwsgi.ini
sed -ri "s@^(max-requests=).*@\1$UWSGI_MAX_REQUESTS@" /etc/uwsgi/uwsgi.ini

#[[ -n $PIP_INSTALL ]] && pip install $PIP_INSTALL

python /usr/local/bin/supervisord -n -c /etc/supervisord.conf
