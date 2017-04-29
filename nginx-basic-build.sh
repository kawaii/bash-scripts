#!/bin/bash
export NGINX_VERSION=1.13.0
export CORE_TOOLS=(build-essential checkinstall curl git libgd-dev libgeoip-dev libpcre3 libpcre3-dev libssl-dev wget)

apt-get update
apt-get -y install ${CORE_TOOLS[*]}

mkdir -p /opt/build
rm -rf /opt/build/*
cd /opt/build

wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -xvzf nginx-${NGINX_VERSION}.tar.gz

rm nginx-${NGINX_VERSION}.tar.gz

cd nginx-${NGINX_VERSION}/

useradd --no-create-home nginx
mkdir -p /var/cache/nginx /usr/lib/nginx/modules

./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --user=nginx \
        --group=nginx \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_geoip_module \
        --with-http_mp4_module \
        --with-http_gzip_static_module \
        --with-http_gunzip_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-http_secure_link_module \
        --with-http_addition_module \
        --with-file-aio \
        --with-threads \
        --with-stream \
        --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-debug \
        --without-mail_pop3_module \
        --without-mail_smtp_module \
        --without-mail_imap_module \

sleep 3

make && sleep 3
make install && sleep 3

mkdir -p /var/www/website
touch /var/www/website/index.html
echo "Hello, world!" >> /var/www/website/index.html
chown -R www-data:www-data /var/www
