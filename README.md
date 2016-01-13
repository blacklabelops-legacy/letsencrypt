Docker container wrapping letsencrypt functionality

Not working work-in-progress!

# Note

Does not work in development environment. Letsencrypt does a bidirectional handshake with Letsencrypt.org, this means that
the container must be reachable under the respective domain name.

# Make It Short!

In short, you can create and renew letsencrypt ssl certificates!

Example:

~~~~
$ docker run -it --rm \
    --name letsencrypt \
    blacklabelops/letsencrypt bash
~~~~

> Will print "hello world" to console every second.
