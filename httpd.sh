#!/usr/bin/env bash
 socat TCP4-LISTEN:8080,fork EXEC:/bin/bashhttpd