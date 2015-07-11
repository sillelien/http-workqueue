#!/usr/bin/env bash
prefix="http://${QUEUE_PORT_8080_TCP_ADDR}:${QUEUE_PORT_8080_TCP_PORT}"
task1=$(curl ${prefix}/enqueue/google.com/?q=test)
(( $task1 == 0 ))


curl ${prefix}/execute/google.com/?q=test
