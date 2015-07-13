#!/usr/bin/env bash
set -e
prefix="http://${QUEUE_PORT_8080_TCP_ADDR}:${QUEUE_PORT_8080_TCP_PORT}"
task1=$(curl ${prefix}/enqueue/google.com/?q=test)
curl ${prefix}/queue/${task1}/wait
status1=$(curl ${prefix}/queue/${task1}/status)
echo $status1
out1=$(curl ${prefix}/queue/${task1}/stdout)
err1=$(curl ${prefix}/queue/${task1}/stderr)
assert1=$(curl --silent --output /dev/stdout --write-out "%{http_code}" ${prefix}/queue/${task1}/assert/HTML | cut -d' ' -f1)
(($assert1 == 200))
echo "****************"
echo "All tests passed"
echo "****************"
#curl ${prefix}/execute/google.com/?q=test
