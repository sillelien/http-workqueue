#!/usr/bin/env bash

exec websocketd --port=8888 --dir=/ws-scripts --cgidir=/cgi-scripts --passenv AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY
