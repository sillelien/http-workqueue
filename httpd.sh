#!/usr/bin/env bash
set -ex
while true
do {
    echo -e 'HTTP/1.1 200 OK\r\n'
 } | nc -l 8080
done

