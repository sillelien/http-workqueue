FROM vizzbuzz/base-alpine
RUN apk update && apk upgrade && apk add curl ca-certificates make gcc build-base bash socat && \
 curl http://vicerveza.homeunix.net/~viric/soft/ts/ts-0.7.5.tar.gz > /tmp/ts-0.7.5.tar.gz && \
 cd /tmp && tar -zxvf ts-0.7.5.tar.gz && cd ts-0.7.5/ && make && make install && \
 curl -L https://github.com/lonelycode/tyk/releases/download/1.7.1/tyk-linux-amd64-1.7.1.tar.gz > /tmp/tyk-linux-amd64-1.7.1.tar.gz && \
 tar -zxvf /tmp/tyk-linux-amd64-1.7.1.tar.gz && \
 mv tyk.linux.amd64-1.7.1 /usr/local/tyk && \
 mkdir -p /etc/tyk/ && \
 mv /usr/local/tyk/templates /etc/tyk/ && \
 apk del build-base make gcc && \
 rm -rf /tmp/*

COPY etc/* /etc/
COPY bin/*.sh /bin/
COPY bin/httpd.sh /etc/services.d/httpd/run
RUN chmod 755 /etc/services.d/httpd/run  /bin/*.sh
RUN /usr/local/bin/ts

EXPOSE 8080