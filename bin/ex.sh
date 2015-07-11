#!/usr/bin/env bash
if [[ -n $TUTUM_AUTH ]]
then
    exec /bin/tutum-ex.sh
else
    exec /bin/local-ex.sh
fi
