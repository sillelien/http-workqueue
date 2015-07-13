#!/usr/bin/env bash
log.sh debug "Executing (with timeout): curl  -X $REQUEST_METHOD http://${1}/${2} "
timeout $(</etc/tasks/timeout)  curl  -X $REQUEST_METHOD http://${1}/${2}  2> /tasks/${REQ_ID}/stderr | tee /tasks/${REQ_ID}/stdout
true