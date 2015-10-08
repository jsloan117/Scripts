#!/bin/bash
#====================================================================
# Name:         transmission_installer.sh
# By:           Jonathan M. Sloan <jsloan@macksarchive.com>
# Date:         04-22-2015
# Purpose:      Install transmission version 2.84 daemon/cli included
# Version:      1.0
#====================================================================

# Take input for username and password
#read -p "Transmission username: " uname
uname=transmission
read -p "$uname's Password: " passw

# Update system and install required packages
yum -y -q update && yum -y -q groupinstall 'Development tools' && yum -y -q install cmake ccache;
yum -y -q install gcc gcc-c++ m4 make automake curl-devel intltool libtool gettext openssl-devel perl-Time-HiRes wget

#Create UNIX user and directories for transmission
encrypt_pass=$(perl -e 'print crypt($ARGV[0], "password")' $passw)
useradd -d /var/lib/$uname -p $encrypt_pass $uname

# Install libevent
cd /usr/local/src
wget https://sourceforge.net/projects/levent/files/libevent/libevent-2.0/libevent-2.0.22-stable.tar.gz -O libevent-2.0.22-stable.tar.gz
tar -xaf libevent-2.0.22-stable.tar.gz
cd libevent-2.0.22-stable
./configure --prefix=/usr
make
make install

# Where are those libevent libraries?
echo /usr/lib > /etc/ld.so.conf.d/libevent-i386.conf
echo /usr/lib > /etc/ld.so.conf.d/libevent-x86_64.conf
ldconfig
export PKG_CONFIG_PATH=/usr/lib/pkgconfig

# Install transmission
cd /usr/local/src
wget https://transmission.cachefly.net/transmission-2.84.tar.xz -O transmission-2.84.tar.xz
tar -xaf transmission-2.84.tar.xz
cd transmission-2.84
./configure --prefix=/usr --enable-daemon --enable-cli
make
make install

# Set up init script for transmission-daemon
git clone https://github.com/jsloan117/Scripts.git
mv Scripts/transmission-daemon /etc/init.d
chmod 755 /etc/init.d/transmission-daemon
chkconfig --add transmission-daemon	
chkconfig --level 345 transmission-daemon on
rm -rf Scripts

# Start transmission-daemon service
service transmission-daemon start
