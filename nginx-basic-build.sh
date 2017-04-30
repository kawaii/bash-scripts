#!/bin/bash
if (( $EUID != 0 )); then
    printf "\nYo, you need to run this script as \033[0;31mroot\033[0m or \033[0;31msudo\033[0m dawg! ¯\_(ツ)_/¯\n\n"
    exit
fi

export NGINX_VERSION=1.13.0
export OPENSSL_VERSION=0453163e9a9052884cce288ff3e2acb77725a239
export CORE_TOOLS=(build-essential checkinstall curl git libgd-dev libgeoip-dev libpcre3 libpcre3-dev libssl-dev ltrace wget)
export EXTRA_TOOLS=(htop nano rsync screenfetch sudo zsh zsh-doc)

apt-get update
apt-get -y install ${CORE_TOOLS[*]}

printf "\nWould you like to install some \033[0;32moptional\033[0m tools in addition to the core build toolkit? [Y/N]\n"
read -r answer
if [[ $answer =~ ^([yY][eE][sS]|[yY])+$ ]] ; then
apt-get -y install ${EXTRA_TOOLS[*]}
fi

cd /opt/

printf "\nWould you like to download the latest version of \033[1;35mcertbot\033[0m (Let's Encrypt client) from GitHub? [Y/N]\n"
read -r answer
if [[ $answer =~ ^([yY][eE][sS]|[yY])+$ ]] ; then
git clone https://github.com/certbot/certbot.git
fi

mkdir -p /opt/build
rm -rf /opt/build/*
cd /opt/build

git clone https://github.com/openssl/openssl.git
cd /opt/build/openssl
git checkout ${OPENSSL_VERSION}

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
        --with-openssl=/opt/build/openssl

sleep 3

make && sleep 3
make install && sleep 3

mkdir -p /var/www/website
touch /var/www/website/index.html
echo "Hello, world!" >> /var/www/website/index.html
chown -R www-data:www-data /var/www
