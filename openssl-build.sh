#!/bin/bash
if (( $EUID != 0 )); then
    printf "\nYo, you need to run this script as \033[0;31mroot\033[0m or \033[0;31msudo\033[0m dawg! ¯\_(ツ)_/¯\n\n"
    exit
fi

export OPENSSL_VERSION=0453163e9a9052884cce288ff3e2acb77725a239
export CORE_TOOLS=(autoconf automake build-essential checkinstall curl git intltool libcurl4-openssl-dev libevent-dev libgd-dev libgeoip-dev libglib2.0-dev libgtk2.0-dev libnotify-dev libpcre3 libpcre3-dev libssl-dev libtool libxml2-dev pkg-config wget)
export EXTRA_TOOLS=(htop nano ltrace rsync screenfetch sudo strace zsh zsh-doc)

apt-get update
apt-get -y install ${CORE_TOOLS[*]}

printf "\nWould you like to install some \033[0;32moptional\033[0m tools in addition to the core toolkit? [Y/N]\n"
read -r answer
if [[ $answer =~ ^([yY][eE][sS]|[yY])+$ ]] ; then
apt-get -y install ${EXTRA_TOOLS[*]}
fi

mkdir -p /opt/build
rm -rf /opt/build/*
cd /opt/build

git clone https://github.com/openssl/openssl.git
cd /opt/build/openssl
git checkout ${OPENSSL_VERSION}
./config \
        --prefix=/usr

make
make install
