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

task2=$(curl "${prefix}/schedule/in/1/minutes/example.com/")

sleep 125

out2=$(curl ${prefix}/schedule/${task2}/stdout)
echo $out2 | grep "This domain is established to be used for illustrative examples in documents."

assert2=$(curl --silent --output /dev/stdout --write-out "%{http_code}" ${prefix}/schedule/${task2}/assert/illustrative | cut -d' ' -f1)
(($assert2 == 200))

echo "****************"
echo "All tests passed"
echo "****************"
#curl ${prefix}/execute/google.com/?q=test



