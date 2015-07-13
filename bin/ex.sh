#!/usr/bin/env bash
timeout $(</etc/tasks/timeout)  curl  -X $REQUEST_METHOD http://${1}/${2}  2> /tasks/${REQ_ID}/stderr | tee /tasks/${REQ_ID}/stdout
true