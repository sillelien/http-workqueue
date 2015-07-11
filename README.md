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


# Planned Work

The core aim of this service is to support three functions:

   1) Execute/Queue work on a work queue (based on [ts](http://vicerveza.homeunix.net/~viric/soft/ts/))
   
   2) Schedule work at a given time (based on `at`)
   
   3) Schedule repeated work (based on `cron`)

And to demonstrate that we really do forget how to [KISS](https://en.wikipedia.org/wiki/KISS_principle)

[![Keep it Simple](http://3.bp.blogspot.com/-WMySBXYTvJU/TtiDb28x2yI/AAAAAAAAADI/aPDzvtpsuiw/s200/metaphor-for-complexity.gif)](https://en.wikipedia.org/wiki/KISS_principle)
   
[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/)
        
        
[![](https://badge.imagelayers.io/vizzbuzz/http-workqueue.svg)](https://imagelayers.io/?images=vizzbuzz/http-workqueue:latest 'Get your own badge on imagelayers.io')        