#!/usr/bin/env sh
set -ex
cd /tmp

echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
apk update
apk add curl ca-certificates make gcc build-base bash socat coreutils fcron@testing
mkdir -p /etc/tasks



#Task Scheduler
cd /tmp
curl http://vicerveza.homeunix.net/~viric/soft/ts/ts-0.7.5.tar.gz > /tmp/ts-0.7.5.tar.gz
tar -zxvf ts-0.7.5.tar.gz
cd ts-0.7.5/
make
make install


#AT
cd /tmp
apk add bison flex
addgroup -g 77 atd
adduser -D  -G atd -s /bin/false -u 77 atd
mkdir -p /var/spool/cron
cd /tmp/at-3.1.16/
./configure --with-daemon_username=atd --with-daemon_groupname=atd  SENDMAIL=/usr/sbin/sendmail
make install  docdir=/usr/share/doc/at-3.1.16 atdocdir=/usr/share/doc/at-3.1.16

mkdir /cron/
cat > /cron/atd <<EOF
* * * * * /bin/at.sh 2>&1 | logger -p cron.debug -t workqueue -t atd
EOF
echo "app" > /etc/at.allow

#Clean Up
apk del build-base make gcc bison flex
rm -rf /tmp/*
rm -rf /var/cache/apk/*

