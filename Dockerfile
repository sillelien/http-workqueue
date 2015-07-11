FROM vizzbuzz/base-alpine
RUN apk update && apk add curl ca-certificates make gcc build-base bash socat && \
 curl http://vicerveza.homeunix.net/~viric/soft/ts/ts-0.7.5.tar.gz > /tmp/ts-0.7.5.tar.gz && \
 cd /tmp && tar -zxvf ts-0.7.5.tar.gz && cd ts-0.7.5/ && make && make install && apk del build-base make gcc

COPY etc/* /etc/
COPY bin/*.sh /bin/
COPY bin/httpd.sh /etc/services.d/httpd/run
RUN chmod 755 /etc/services.d/httpd/run  /bin/*.sh
RUN /usr/local/bin/ts

EXPOSE 8080