#!/usr/bin/env bash
export PATH=$PATH:/usr/local/bin
socat TCP4-LISTEN:8080,fork EXEC:/bin/bashhttpd.sh