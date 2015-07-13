#!/usr/bin/env sh
set -ex
cd /tmp

logger "Starting build"

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
apk del build-base make gcc bison flex go
rm -rf /tmp/*
rm -rf /var/cache/apk/*

# Glibc (not needed)
#
# cd /tmp && \
#        wget "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk" \
#             "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk" && \
#        apk add --allow-untrusted glibc-2.21-r2.apk glibc-bin-2.21-r2.apk && \
#        /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib && \
#        echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf
