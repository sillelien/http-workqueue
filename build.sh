#!/usr/bin/env sh
set -ex
cd /tmp
apk update
apk upgrade
apk add curl ca-certificates make gcc build-base bash socat

#Task Scheduler
cd /tmp
curl http://vicerveza.homeunix.net/~viric/soft/ts/ts-0.7.5.tar.gz > /tmp/ts-0.7.5.tar.gz
tar -zxvf ts-0.7.5.tar.gz
cd ts-0.7.5/
make
make install

#Tyk
cd /tmp
curl -L https://github.com/lonelycode/tyk/releases/download/1.7.1/tyk-linux-amd64-1.7.1.tar.gz > /tmp/tyk-linux-amd64-1.7.1.tar.gz
tar -zxvf /tmp/tyk-linux-amd64-1.7.1.tar.gz
mv tyk.linux.amd64-1.7.1 /usr/local/tyk
mkdir -p /etc/tyk/
mv /usr/local/tyk/templates /etc/tyk/

#AT
cd /tmp
apk add bison flex
addgroup -g 77 atd
adduser -D  -G atd -s /bin/false -u 77 atd
mkdir -p /var/spool/cron
cd /tmp/at-3.1.16/
./configure --with-daemon_username=atd --with-daemon_groupname=atd  SENDMAIL=/usr/sbin/sendmail
make install  docdir=/usr/share/doc/at-3.1.16 atdocdir=/usr/share/doc/at-3.1.16

#Clean Up
apk del build-base make gcc bison flex
rm -rf /tmp/*

# Glibc (not needed)
#
# cd /tmp && \
#        wget "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk" \
#             "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk" && \
#        apk add --allow-untrusted glibc-2.21-r2.apk glibc-bin-2.21-r2.apk && \
#        /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib && \
#        echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf
