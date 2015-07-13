#Work In Progress

Please understand this is a work in progress, you may wish to play around with it, just to get a feel of what it will do.

# Http Work Queue

The idea behind this container is to provide a very simple work queue driven by the HTTP protocol. You make requests of this container to make requests upon another service, however execution of these requests are moderated by a work queue (see [Task Spooler](http://vicerveza.homeunix.net/~viric/soft/ts/) for the underlying mechanism)

It is usually called from a linked container using:

```bash
curl http://${QUEUE_PORT_8080_TCP_ADDR}:${QUEUE_PORT_8080_TCP_PORT}/execute/google.com/?q=hello
```

In this simple example we are requesting execution of a GET method on http://google.com/?=hello on the work queue and we want to get the result synchronously.

Or we could queue the execution using:

```bash
curl http://${QUEUE_PORT_8080_TCP_ADDR}:${QUEUE_PORT_8080_TCP_PORT}/enqueue/google.com/?q=hello
```

This returns the queue id of the request, which can be used to see the result at a later time.



# Introduction

```bash
#!/usr/bin/env bash
set -ex
prefix="http://${QUEUE_PORT_8080_TCP_ADDR}:${QUEUE_PORT_8080_TCP_PORT}"
task1=$(curl ${prefix}/enqueue/google.com/?q=test)
curl ${prefix}/queue/${task1}/wait
assert1=$(curl --silent --output /dev/stdout--write-out "%{http_code}" ${prefix}/queue/${task1}/assert/HTML| cut -d' ' -f1)
(($assert1 == 200))

out1=$(curl ${prefix}/queue/${task1}/stdout)
err1=$(curl ${prefix}/queue/${task1}/stderr)
```

The above is an example of how you use http-workqueue, it actually comes from the test script. Here you see a task being queued

```bash
task1=$(curl ${prefix}/enqueue/google.com/?q=test)
```

We then wait for it to be executed

```bash
curl ${prefix}/queue/${task1}/wait
```

Of course we can be busy doing something else at this time. Next we assert that HTML is within the body of the result and get the HTTP code returned to check to see if it's 200 (it will be 404 if the assertion failed)

```bash
assert1=$(curl --silent --output /dev/stdout --write-out "%{http_code}" ${prefix}/queue/${task1}/assert/HTML| cut -d' ' -f1)
(($assert1 == 200))
```

Finally we request the stdout and stderr of the command:

```bash
out1=$(curl ${prefix}/queue/${task1}/stdout)
err1=$(curl ${prefix}/queue/${task1}/stderr)
```

# Planned Work

The core aim of this service is to support three functions:

   1) Execute/Queue work on a work queue (based on [ts](http://vicerveza.homeunix.net/~viric/soft/ts/))
   
   2) Schedule work at a given time (based on `at`)
   
   3) Schedule repeated work (based on `cron`)

And to demonstrate that we really do forget how to [KISS](https://en.wikipedia.org/wiki/KISS_principle)

[![Keep it Simple](http://3.bp.blogspot.com/-WMySBXYTvJU/TtiDb28x2yI/AAAAAAAAADI/aPDzvtpsuiw/s200/metaphor-for-complexity.gif)](https://en.wikipedia.org/wiki/KISS_principle)
   
[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/)
        
        
[![](https://badge.imagelayers.io/vizzbuzz/http-workqueue.svg)](https://imagelayers.io/?images=vizzbuzz/http-workqueue:latest 'Get your own badge on imagelayers.io')        