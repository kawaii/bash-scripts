#!/bin/bash
if [[ $EUID != 0 ]]; then
    printf "\nYo, you need to run this script as \033[0;31mroot\033[0m or \033[0;31msudo\033[0m dawg! ¯\_(ツ)_/¯\n\n"
    exit
fi

export MYBB_VERSION=1811
export FORUM_DIR="mybb"
export EXTRA_TOOLS=(apt-transport-https ca-certificates curl git htop nano lsb-release rsync unzip wget zsh)
export PHP_BINARIES=(php7.0-bz2 php7.0-curl php7.0-fpm php7.0-gd php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-pgsql php7.0-xml php7.0-zip)

apt-get -y install ${EXTRA_TOOLS[*]}

wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
apt-get update

apt-get -y install ${PHP_BINARIES[*]}

mkdir -p /var/www/${FORUM_DIR}
cd /var/www/${FORUM_DIR}

wget https://resources.mybb.com/downloads/mybb_${MYBB_VERSION}.zip
unzip mybb_${MYBB_VERSION}.zip

mv Upload/ .
rm -rf Documentation/
rm -rf mybb_${MYBB_VERSION}.zip

cp inc/config.default.php inc/config.php

chmod 666 inc/config.php inc/settings.php
chmod 777 cache/ cache/themes/ uploads/ uploads/avatars/
chmod 666 inc/languages/english/*.php inc/languages/english/admin/*.php
chmod 777 cache/ cache/themes/ uploads/ uploads/avatars/ admin/backups/

printf "\n\033[0;32mComplete!\033[0m\n\n"
