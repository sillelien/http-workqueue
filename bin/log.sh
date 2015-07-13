#!/usr/bin/env bash
level=$1
shift
exec logger -s -p user.${level} -t workqueue -- $@
