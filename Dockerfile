FROM openjdk:15-ea-slim
FROM php:7.3-apache

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ENV JAVA_HOME /usr/local/openjdk-15
ENV PATH $JAVA_HOME/bin:$PATH

COPY --from=0 $JAVA_HOME $JAVA_HOME
COPY --from=0 /etc/ca-certificates/update.d/docker-openjdk /etc/ca-certificates/update.d/docker-openjdk
COPY --from=0 /etc/ld.so.conf.d/docker-openjdk.conf /etc/ld.so.conf.d/docker-openjdk.conf

RUN set -eux; \
# basic smoke test
	ldconfig; \
	javac --version; \
	java --version; \
# install required modules for Siberian SAE
	apt-get update; \
	apt-get install -y zip zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev wget; \
	docker-php-ext-configure gd --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ --with-freetype-dir=/usr/lib/x86_64-linux-gnu/ ; \
	docker-php-ext-install gd pdo_mysql; \
	a2enmod rewrite; \
# enable Apache modules for reverse proxy support
	a2enmod remoteip; \
	a2enmod headers; \
	a2enmod setenvif; \
# all done
	apt-get purge -y --auto-remove;

COPY config/siberian.ini $PHP_INI_DIR/conf.d/
COPY config/auto_prepend.php /usr/local/etc/php/reverse-proxy-prepend.php
COPY config/apache-reverse-proxy.conf /etc/apache2/conf-available/
RUN a2enconf apache-reverse-proxy
COPY config/index.php /var/www/html/
