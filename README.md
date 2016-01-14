# Let's Encrypt Docker Image

Docker Image wrapping Let's Encrypt Standalone Server.

Work-In-Progress!

Features:

* Initial setup of letsencrypt certificates
* Automatic renewal of letsencrypt certificates each month
* Manual creation of new certificates.
* Manual renewal of certificates.

# Note

Does not work in development environment. Let's Encrypt does a bidirectional handshake with Letsencrypt.org, this means that
the container must be reachable under the respective domain name (e.g. mysubdomain.example.com).

# Make It Short!

In short, you can create and renew let's encrypt ssl certificates!

First start a data container where the certificate will be stored.

~~~~
$ docker run -d \
    -v /etc/letsencrypt \
    --name letsencrypt_data \
    blacklabelops/centos bash
~~~~

> Letsencrypt stores the certificates inside the folder /etc/letsencrypt

Then generate the certificates. This is a one time operation!

Example:

~~~~
$ docker run --rm \
    -p 80:80 \
    -p 443:443 \
    --name letsencrypt \
    --volumes-from letsencrypt_data \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=subdomain.example.com" \
    blacklabelops/letsencrypt install
~~~~

> Will generate the certificates inside the folder /etc/letsencrypt. If you want to add new certificates then use 'renew' instead of 'install'.

Now setup the container for monthly renewal!

~~~~
$ docker run --rm \
    -p 80:80 \
    -p 443:443 \
    --name letsencrypt \
    --volumes-from letsencrypt_data \
    -e "LETSENCRYPT_DOMAIN1=jenkins.blacklabelops.com" \
    blacklabelops/letsencrypt
~~~~

> Will renew the specified certificates on 15. of each month.

# Let's Encrypt Domains

You can specify multiple domain which will be handled by the image. Each domain must be followed by a number:

Example:

* Domain1: subdomain1.example.com
* Domain2: www.quitschie.com
* Domain3: mydomain.squeeze.de

Will result in:

~~~~
$ docker run -d \
    -p 80:80 \
    -p 443:443 \
    --name letsencrypt \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=subdomain1.example.com" \
    -e "LETSENCRYPT_DOMAIN2=www.quitschie.com" \
    -e "LETSENCRYPT_DOMAIN3=mydomain.squeeze.de" \
    blacklabelops/letsencrypt
~~~~

> Will renew the certificates inside its volume /etc/letsencrypt

# Choosing between HTTP and HTTPS

Let's encrypt uses either HTTP port 80 or HTTPS port 443 for autenticating the domains.

Choose according to the port which is free in your environment and disable the other with
the environment variables HTTP_ENABLED and HTTPS_ENABLED. Both are true by default.

Example using HTTP only:

~~~~
$ docker run -d \
    -p 80:80 \
    --name letsencrypt \
    -e "HTTPS_ENABLED=false" \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=subdomain1.example.com" \
    blacklabelops/letsencrypt
~~~~

> Will renew the certificates inside its volume /etc/letsencrypt

Example using HTTPS only:

~~~~
$ docker run -d \
    -p 443:443 \
    --name letsencrypt \
    -e "HTTP_ENABLED=false" \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=subdomain1.example.com" \
    blacklabelops/letsencrypt
~~~~

> Will renew the certificates inside its volume /etc/letsencrypt

# Multiple Accounts

Multiple installations will result in multiple accounts inside /etc/letsencrypt/. Multiple installations need an account id in order to make the container work!

The account id's can be found inside the folder: /etc/letsencrypt/accounts/acme-v01.api.letsencrypt.org/directory

Now specify the account id with the environment variable LETSENCRYPT_ACCOUNT_ID.

Example:

~~~~
$ docker run -d \
    -p 80:80 \
    --name letsencrypt \
    -e "HTTPS_ENABLED=false" \
    -e "LETSENCRYPT_ACCOUNT_ID=YOUR_ACCOUNT_ID_HERE" \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=subdomain1.example.com" \
    blacklabelops/letsencrypt
~~~~

> Will renew the certificates inside its volume /etc/letsencrypt for the specific account.

# References

* [Let’s Encrypt](https://letsencrypt.org/)
* [Letsencrypt-Auto](https://github.com/letsencrypt/letsencrypt)
* [Letsencrypt-Auto Docs](http://letsencrypt.readthedocs.org/en/latest/index.html)
* [Jobber](https://github.com/dshearer/jobber)
* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
