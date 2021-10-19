FROM alpine:3.14

RUN apk add --update \
		lighttpd \
		php7-fpm php7-session php7-dom php7-pdo_mysql \
		runit \
	&& rm -rf /var/cache/apk/*

# set up folders, configure lighttpd and php-fpm
RUN mkdir -p /app/htdocs /app/logs /etc/service/lighttpd /etc/service/php-fpm /etc/service/syslogd \
	&& chmod 777 /app/logs \
	&& sed -i -E \
		-e 's/var\.basedir\s*=\s*".*"/var.basedir = "\/app"/' \
		-e 's/(server\.errorlog\s*=.*)/# \1/' \
		-e 's/(accesslog\.filename\s*=.*)/# \1/' \
		-e 's/#\s+(include "mod_fastcgi_fpm.conf")/\1/' \
		-e 's/#\s+(server\.errorlog-use-syslog\s*=\s*"enable")/\1/' \
		/etc/lighttpd/lighttpd.conf \
	&& echo -e "accesslog.use-syslog =\"enable\"" >>/etc/lighttpd/lighttpd.conf \
	&& echo -e "#!/bin/sh\nlighttpd -D -f /etc/lighttpd/lighttpd.conf" > /etc/service/lighttpd/run \
	&& echo -e "#!/bin/sh\nphp-fpm7 --nodaemonize" > /etc/service/php-fpm/run \
	&& echo -e "#!/bin/sh\n/sbin/syslogd -n -O /dev/stderr" > /etc/service/syslogd/run \
	&& chmod -R +x /etc/service/*


EXPOSE 80

WORKDIR /app/htdocs

CMD runsvdir -P /etc/service

