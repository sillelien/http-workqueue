#!/usr/bin/env bash
#
#  Copyright (C) 2012, Avleen Vig <avleen@gmail.com>
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy of
#  this software and associated documentation files (the "Software"), to deal in
#  the Software without restriction, including without limitation the rights to
#  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
#  the Software, and to permit persons to whom the Software is furnished to do so,
#  subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
#  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
#  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
#  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
# A simple, configurable HTTP server written in bash.
#
# See LICENSE for licensing information.
#
# Original author: Avleen Vig, 2012
# Reworked by:     Josh Cartwright, 2012

warn() { echo "WARNING: $@" >&2; }
recv() { echo "< $@" >&2; }
send() { echo "> $@" >&2;
         printf '%s\n' "$*"; }

[[ $UID = 0 ]] && warn "It is not recommended to run bashttpd as root."

DATE=$(date +"%a, %d %b %Y %H:%M:%S %Z")
declare -a RESPONSE_HEADERS=(
      "Date: $DATE"
   "Expires: $DATE"
    "Server: Slash Bin Slash Bash"
)

add_response_header() {
   RESPONSE_HEADERS+=("$1: $2")
}

declare -a HTTP_RESPONSE=(
   [200]="OK"
   [400]="Bad Request"
   [403]="Forbidden"
   [404]="Not Found"
   [405]="Method Not Allowed"
   [500]="Internal Server Error"
)

send_response() {
   local code=$1
   send "HTTP/1.0 $1 ${HTTP_RESPONSE[$1]}"
   for i in "${RESPONSE_HEADERS[@]}"; do
      send "$i"
   done
   send
   while read -r line; do
      send "$line"
   done
}

send_response_ok_exit() { send_response 200; exit 0; }

fail_with() {
   send_response "$1" <<< "$1 ${HTTP_RESPONSE[$1]}"
   exit 1
}

serve_file() {
   local file=$1

   CONTENT_TYPE=
   case "$file" in
     *\.css)
       CONTENT_TYPE="text/css"
       ;;
     *\.js)
       CONTENT_TYPE="text/javascript"
       ;;
     *)
       read -r CONTENT_TYPE   < <(file -b --mime-type "$file")
       ;;
   esac

   add_response_header "Content-Type"   "$CONTENT_TYPE";

   read -r CONTENT_LENGTH < <(stat -c'%s' "$file")         && \
      add_response_header "Content-Length" "$CONTENT_LENGTH"

   send_response_ok_exit < "$file"
}

serve_dir_with_tree()
{
   local dir="$1" tree_vers tree_opts basehref x

   add_response_header "Content-Type" "text/html"

   # The --du option was added in 1.6.0.
   read x tree_vers x < <(tree --version)
   [[ $tree_vers == v1.6* ]] && tree_opts="--du"

   send_response_ok_exit < \
      <(tree -H "$2" -L 1 "$tree_opts" -D "$dir")
}

serve_dir_with_ls()
{
   local dir=$1

   add_response_header "Content-Type" "text/plain"

   send_response_ok_exit < \
      <(ls -la "$dir")
}

serve_dir() {
   local dir=$1

   # If `tree` is installed, use that for pretty output.
   which tree &>/dev/null && \
      serve_dir_with_tree "$@"

   serve_dir_with_ls "$@"

   fail_with 500
}

serve_dir_or_file_from() {
   local URL_PATH=$1/$3
   shift

   # sanitize URL_PATH
   URL_PATH=${URL_PATH//[^a-zA-Z0-9_~\-\.\/]/}
   [[ $URL_PATH == *..* ]] && fail_with 400

   # Serve index file if exists in requested directory
   [[ -d $URL_PATH && -f $URL_PATH/index.html && -r $URL_PATH/index.html ]] && \
      URL_PATH="$URL_PATH/index.html"

   if [[ -f $URL_PATH ]]; then
      [[ -r $URL_PATH ]] && \
         serve_file "$URL_PATH" "$@" || fail_with 403
   elif [[ -d $URL_PATH ]]; then
      [[ -x $URL_PATH ]] && \
         serve_dir  "$URL_PATH" "$@" || fail_with 403
   fi

   fail_with 404
}

serve_static_string() {
   add_response_header "Content-Type" "text/plain"
   send_response_ok_exit <<< "$1"
}

on_uri_match() {
   local regex=$1
   shift

   [[ $REQUEST_URI =~ $regex ]] && \
      "$@" "${BASH_REMATCH[@]}"
}

unconditionally() {
   "$@" "$REQUEST_URI"
}

# Request-Line HTTP RFC 2616 $5.1
read -r line || fail_with 400

# strip trailing CR if it exists
line=${line%%$'\r'}
recv "$line"

read -r REQUEST_METHOD REQUEST_URI REQUEST_HTTP_VERSION <<<"$line"

[ -n "$REQUEST_METHOD" ] && \
[ -n "$REQUEST_URI" ] && \
[ -n "$REQUEST_HTTP_VERSION" ] \
   || fail_with 400

# Only GET is supported at this time
[ "$REQUEST_METHOD" = "GET" ] || fail_with 405

declare -a REQUEST_HEADERS

while read -r line; do
   line=${line%%$'\r'}
   recv "$line"

   # If we've reached the end of the headers, break.
   [ -z "$line" ] && break

   REQUEST_HEADERS+=("$line")
done

source /etc/bashhttpd.conf
fail_with 500