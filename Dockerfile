FROM vizzbuzz/base-alpine
COPY at-3.1.16/ /tmp/at-3.1.16/
COPY build.sh build.sh
RUN chmod 755 build.sh
RUN ./build.sh

RUN atd
COPY etc/* /etc/
COPY bin/*.sh /bin/
COPY bin/httpd.sh /etc/services.d/httpd/run
RUN chmod 755 /etc/services.d/httpd/run  /bin/*.sh

EXPOSE 8080