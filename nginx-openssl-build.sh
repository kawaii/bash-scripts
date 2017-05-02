#!/bin/bash
if [[ $EUID != 0 ]]; then
    printf "\nYo, you need to run this script as \033[0;31mroot\033[0m or \033[0;31msudo\033[0m dawg! ¯\_(ツ)_/¯\n\n"
    exit
fi

export NGINX_VERSION=1.13.0
export OPENSSL_VERSION=0453163e9a9052884cce288ff3e2acb77725a239
export CORE_TOOLS=(build-essential checkinstall curl git libgd-dev libgeoip-dev libpcre3 libpcre3-dev libssl-dev wget)
export EXTRA_TOOLS=(htop nano ltrace rsync screenfetch sudo strace zsh zsh-doc)

printf "\nWould you like to install some \033[0;32moptional\033[0m tools in addition to the core toolkit? [Y/N]\n\n"
read -r answer
if [[ $answer =~ ^([yY][eE][sS]|[yY])+$ ]] ; then
MORE_TOOLS=1
fi

printf "\nWould you like to download the latest version of \033[1;35mcertbot\033[0m (Let's Encrypt client) from GitHub? [Y/N]\n\n"
read -r answer
if [[ $answer =~ ^([yY][eE][sS]|[yY])+$ ]] ; then
CERTBOT=1
fi

apt-get update
apt-get -y install ${CORE_TOOLS[*]}

if [[ $MORE_TOOLS = 1 ]]; then
apt-get -y install ${EXTRA_TOOLS[*]}
fi

cd /opt/

if [[ $CERTBOT = 1 ]]; then
git clone https://github.com/certbot/certbot.git
fi

mkdir -p /opt/build
rm -rf /opt/build/*
cd /opt/build

git clone https://github.com/kyprizel/testcookie-nginx-module.git
git clone https://github.com/openresty/headers-more-nginx-module.git

git clone https://github.com/openssl/openssl.git
cd /opt/build/openssl
git checkout ${OPENSSL_VERSION}

cd /opt/build

wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc
wget https://nginx.org/keys/aalexeev.key && gpg --import aalexeev.key
wget https://nginx.org/keys/is.key && gpg --import is.key
wget https://nginx.org/keys/mdounin.key && gpg --import mdounin.key
wget https://nginx.org/keys/maxim.key && gpg --import maxim.key
wget https://nginx.org/keys/sb.key && gpg --import sb.key
gpg --verify nginx-${NGINX_VERSION}.tar.gz.asc nginx-${NGINX_VERSION}.tar.gz

sleep 3

if (( $? != 0 )); then
printf "\n\033[1;31mWARNING: COULD NOT VERIFY SOURCE CODE SIGNATURE, ARE YOU SURE YOU WISH TO CONTINUE? [Y/N]\033[0m\n\n"
read -r answer
if [[ $answer =~ ^([nN][oO]|[nN])+$ ]] ; then
exit
fi
fi

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
        --user=www-data \
        --group=www-data \
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
        --with-openssl=/opt/build/openssl \
        --add-module=/opt/build/testcookie-nginx-module \
        --add-module=/opt/build/headers-more-nginx-module

make
make install

mkdir -p /var/www/website
touch /var/www/website/index.html
echo "Hello, world!" >> /var/www/website/index.html
chown -R www-data:www-data /var/www
