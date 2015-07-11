#Work In Progress

Please understand this is a work in progress, you may wish to play around with it, just to get a feel of what it will do.

# Http Work Queue

The idea behind this container is to provide a very simple work queue driven by the HTTP protocol.

It is usually called from a linked container using:

```bash
curl http://${QUEUE_PORT_8080_TCP_ADDR}:${QUEUE_PORT_8080_TCP_PORT}/execute/google.com/?q=hello
```

In this simple example we are requesting immediate execution of a GET method on http://google.com/?=hello

Or we could queue the execution using:

```bash
curl http://${QUEUE_PORT_8080_TCP_ADDR}:${QUEUE_PORT_8080_TCP_PORT}/enqueue/google.com/?q=hello
```

This returns the queue id of the request, which can be used to see the result at a later time.


[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/)
        
        
[![](https://badge.imagelayers.io/vizzbuzz/http-workqueue.svg)](https://imagelayers.io/?images=vizzbuzz/http-workqueue:latest 'Get your own badge on imagelayers.io')        