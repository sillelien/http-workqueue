#!/usr/bin/env bash
#set -x
mkdir -p /tasks/$REQ_ID
uuidregex="([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})"
hostregex="([a-zA-Z_.0-9-]*)"
scheduleregex="([a-zA-Z_.0-9: +-]*)"

serve_pong() {
    add_response_header "Content-Type" "text/plain"
    send_response_ok_exit <<< "pong $2"
    exit 0
}
on_uri_match '^/ping/(.*)$' serve_pong

serve_enqueue() {
    add_response_header "Content-Type" "text/plain"
    add_response_header "X-Task-Id" "$REQ_ID"
    task=$(ts -n ex.sh "$2" "$3")
    echo $task > /tasks/$REQ_ID/ts.id.txt
    send_response_ok_exit <<< "$REQ_ID"
    exit 0

}
on_uri_match "^/enqueue/${hostregex}/(.*)$" serve_enqueue
on_uri_match "^/queue/add/${hostregex}/(.*)$" serve_enqueue


serve_queue() {
    add_response_header "Content-Type" "text/plain"
    add_response_header "X-Task-Id" "$2"
    task_id=$(</tasks/$2/ts.id.txt)
    export argument=$1
    result=$(ts -n "-${argument}" ${task_id})
    send_response_ok_exit <<< "$result"
    exit 0

}

serve_queue_status() { serve_queue i $2; }
on_uri_match "^/queue/${uuidregex}/status" serve_queue_status

serve_queue_delete() { serve_queue r $2; }
on_uri_match "^/queue/${uuidregex}/delete" serve_queue_delete

serve_queue_wait() { serve_queue w $2; }
on_uri_match "^/queue/${uuidregex}/wait" serve_queue_wait

serve_queue_assert() {
    add_response_header "Content-Type" "text/plain"
    add_response_header "X-Task-Id" "$2"
    if grep "$3" /tasks/$2/stdout &> /dev/null
    then
        send_response_ok_exit < /dev/null
    else
        fail_with 404
    fi
    exit 0

}
on_uri_match "^/queue/${uuidregex}/assert/(.*)" serve_queue_assert
on_uri_match "^/schedule/${uuidregex}/assert/(.*)" serve_queue_assert


serve_queue_stdout() {
    add_response_header "Content-Type" "text/plain"
    add_response_header "X-Task-Id" "$2"
    if [[ -f /tasks/$2/stdout ]]
    then
        send_response_ok_exit < /tasks/$2/stdout
    else
        fail_with 404
    fi
    exit 0

}
on_uri_match "^/queue/${uuidregex}/stdout" serve_queue_stdout
on_uri_match "^/schedule/${uuidregex}/stdout" serve_queue_stdout


serve_queue_stderr() {
    add_response_header "Content-Type" "text/plain"
    add_response_header "X-Task-Id" "$2"
    if [[ -f /tasks/$2/stderr ]]
    then
        send_response_ok_exit < /tasks/$2/stderr
    else
        fail_with 404
    fi
    exit 0

}
on_uri_match "^/queue/${uuidregex}/stderr" serve_queue_stderr
on_uri_match "^/schedule/${uuidregex}/stderr" serve_queue_stderr

serve_execute() {
    add_response_header "Content-Type" "text/plain"
    add_response_header "X-Task-Id" "$REQ_ID"

    task=$(ts -n ex.sh "$2" "$3")
    echo "TS Task: $task"  1>&2
    echo $task > /tasks/$REQ_ID/ts.id.txt
    ts -w $task
    cat /tasks/$REQ_ID/stdout 1>&2
    send_response_ok_exit < /tasks/$REQ_ID/stdout
    exit 0
}
on_uri_match "^/execute/${hostregex}/(.*)$" serve_execute
on_uri_match "^/queue/run/${hostregex}/(.*)$" serve_execute


schedule_execute() {
    add_response_header "Content-Type" "text/plain"
    add_response_header "X-Task-Id" "$REQ_ID"

    task=$(echo ex.sh \"$4\" \"$5\" | at -t "$3 $2" 2>&1 | cut -d' ' -f2)
    echo $task > /tasks/$REQ_ID/at.id.txt
    send_response_ok_exit <<< "$REQ_ID"
    exit 0
}
on_uri_match "^/schedule/at/${scheduleregex}/${scheduleregex}/${hostregex}/(.*)$" schedule_execute


schedule_execute_in() {
    add_response_header "Content-Type" "text/plain"
    add_response_header "X-Task-Id" "$REQ_ID"

    task=$(echo ex.sh \"$4\" \"$5\" | at "now + $2 $3" 2>&1 | tr -d '\n' | cut -d' ' -f2)
    echo $task > /tasks/$REQ_ID/at.id.txt
    send_response_ok_exit <<< "$REQ_ID"
    exit 0
}
on_uri_match "^/schedule/in/([0-9]+)/(minutes|hours|days|weeks)/${hostregex}/(.*)$" schedule_execute_in

update_cron() {
    cat /cron/* | crontab -
}

schedule_cron() {
    add_response_header "Content-Type" "text/plain"
    add_response_header "X-Task-Id" "$REQ_ID"
    echo "$2 $3 $4 $5 $6 app /bin/ex.sh \"6\" \"$7\"" > /cron/$REQ_ID
    update_cron
    send_response_ok_exit <<< "$REQ_ID"
    exit 0
}
on_uri_match "^/schedule/cron/([0-9]+)/([0-9]+)/([0-9]+)/([0-9]+)/([0-9]+)/${hostregex}/(.*)$" schedule_cron

schedule_cron_delete() {
    add_response_header "Content-Type" "text/plain"
    add_response_header "X-Task-Id" "$REQ_ID"
    rm -f /cron/$2
    update_cron
    send_response_ok_exit <<< "$REQ_ID"
    exit 0
}
on_uri_match "^/schedule/cron/${uuidregex}/delete$" schedule_cron
