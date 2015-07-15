#!/usr/bin/with-contenv bash
export PATH=$PATH:/usr/local/bin
echo ${REMOTE_REQUEST_TIMEOUT:-300} > /etc/tasks/timeout
mkdir -p /tasks
chown 999:999 /tasks
s6-applyuidgid -u 999 -g 999 socat TCP4-LISTEN:8080,fork EXEC:/bin/bashhttpd.sh
