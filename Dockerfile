FROM vizzbuzz/base-alpine
RUN apk update && apk add curl ca-certificates make gcc build-base bash socat && \
 curl http://vicerveza.homeunix.net/~viric/soft/ts/ts-0.7.5.tar.gz > /tmp/ts-0.7.5.tar.gz && \
 cd /tmp && tar -zxvf ts-0.7.5.tar.gz && cd ts-0.7.5/ && make && make install && apk del build-base make gcc

#RUN apk update && apk add websocketd
#COPY websocketd.sh /etc/services.d/websocketd/run
#RUN chmod 755 /etc/services.d/websocketd/run

COPY bashhttpd.conf /etc/bashhttpd.conf
COPY bashhttpd.sh /bin/bashhttpd
COPY httpd.sh /etc/services.d/httpd/run
RUN chmod 755 /etc/services.d/httpd/run /bin/bashhttpd
RUN /usr/local/bin/ts

EXPOSE 8080