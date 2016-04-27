# Let's Encrypt Docker Image

Docker Image wrapping Let's Encrypt Standalone Server.

Perfectly working with this reverse proxy: [blacklabelops/nginx](https://github.com/blacklabelops/nginx)

Features:

* Initial setup of letsencrypt certificates
* Automatic renewal of letsencrypt certificates each month
* Manual creation of new certificates.
* Manual renewal of certificates.

# Requirements

Will not work inside your local environment. In order to generate valid certificates you will have to run this container on your internet host. Let's Encrypt does a bidirectional handshake with Letsencrypt.org, this means that the container must be reachable under the respective domain name (e.g. mysubdomain.example.com).

# Make It Short!

In short, you can create and renew let's encrypt ssl certificates!

~~~~
$ docker run --rm \
    -p 80:80 \
    -p 443:443 \
    --name letsencrypt \
    -v $(pwd):/etc/letsencrypt \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=www.example.com" \
    blacklabelops/letsencrypt install
~~~~

> Will generate dummy certificates inside your local folder! If you want to add new certificates then use 'renew' instead of 'install'. Note: This example works in debug mode!

# How It Works

You can create and renew let's encrypt ssl certificates!

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
    -e "LETSENCRYPT_DOMAIN1=www.example.com" \
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
    -e "LETSENCRYPT_DOMAIN1=www.example.com" \
    blacklabelops/letsencrypt
~~~~

> Will renew the specified certificates on 15. of each month.

# Let's Encrypt Domains

You can specify multiple domain which will be handled by the image. Each domain must be followed by a number:

Note: Multiple domains will result in one certificate with the specified domains! Letsencrypt currently takes the
certificate specified with LETSENCRYPT_DOMAIN1 as the certificate name for all subcertificates!

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

> Will renew the certificate inside its volume /etc/letsencrypt/live/subdomain1.example.com

# Choosing between HTTP and HTTPS

Let's encrypt uses either HTTP port 80 or HTTPS port 443 for autenticating the domains.

Choose according to the port which is free in your environment and disable the other with
the environment variables HTTP_ENABLED and HTTPS_ENABLED. Both are true by default.

Example using HTTP only:

~~~~
$ docker run -d \
    -p 80:80 \
    --name letsencrypt \
    -e "LETSENCRYPT_HTTPS_ENABLED=false" \
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
    -e "LETSENCRYPT_HTTP_ENABLED=false" \
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
    -e "LETSENCRYPT_HTTPS_ENABLED=false" \
    -e "LETSENCRYPT_ACCOUNT_ID=YOUR_ACCOUNT_ID_HERE" \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=subdomain1.example.com" \
    blacklabelops/letsencrypt
~~~~

> Will renew the certificates inside its volume /etc/letsencrypt for the specific account.

# Using Let's Encrypt Manually

You can invoke all functionality manually. Supported commands are:

* install: Automatic initial install. If you use this multiple times then letsencrypt will create multiple accounts.
* manualinstall: Manual initial install. If you use this multiple times then letsencrypt will create multiple accounts.
* newcert: Simply generate a new certificate. (Is actually the same as manualrenewal)
* manualrenewal: Manually renewal a certificate. (Is actually the same as newcert)
* renewal: Automatically renew certificate.

Example `install`:

~~~~
$ docker run \
    -p 80:80 \
    -p 443:443 \
    --name letsencrypt \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=subdomain1.example.com" \
    blacklabelops/letsencrypt install
~~~~

Example `manualinstall`:

~~~~
$ docker run -it \
    -p 80:80 \
    -p 443:443 \
    --name letsencrypt \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=subdomain1.example.com" \
    blacklabelops/letsencrypt manualinstall
~~~~

Example `newcert`:

~~~~
$ docker run -it \
    -p 80:80 \
    -p 443:443 \
    --name letsencrypt \
    -e "LETSENCRYPT_DOMAIN1=subdomain1.example.com" \
    blacklabelops/letsencrypt newcert
~~~~

Example `manualrenewal`:

~~~~
$ docker run -it \
    -p 80:80 \
    -p 443:443 \
    --name letsencrypt \
    -e "LETSENCRYPT_DOMAIN1=subdomain1.example.com" \
    blacklabelops/letsencrypt manualrenewal
~~~~

Example `renewal`:

~~~~
$ docker run \
    -p 80:80 \
    -p 443:443 \
    --name letsencrypt \
    -e "LETSENCRYPT_DOMAIN1=subdomain1.example.com" \
    blacklabelops/letsencrypt renewal
~~~~

# Letsencrypt and NGINX

Note: This will not work inside on your local comp. You will have to do this inside your target environment.

First start a data container where the certificate will be stored.

~~~~
$ docker run -d \
    -v /etc/letsencrypt \
    --name letsencrypt_data \
    blacklabelops/centos bash -c "chown -R 1000:1000 /etc/letsencrypt"
~~~~

> Letsencrypt stores the certificates inside the folder /etc/letsencrypt.

Then start the letsencrypt container and create the certificate.

~~~~
$ docker run --rm \
    -p 80:80 \
    -p 443:443 \
    --name letsencrypt \
    --volumes-from letsencrypt_data \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=example.com" \
    blacklabelops/letsencrypt install
~~~~

> This container will handshake with letsencrypt.org and an account and the certificate when successful.

Before we can use them you will have to set the appropriate permissions for the nginx user!

~~~~
$ docker start letsencrypt_data
~~~~

> The data container will repeat the instruction: chown -R 1000:1000 /etc/letsencrypt

Now you can use the certificate for your reverse proxy!

~~~~
$ docker run -d \
    -p 443:44300 \
    --volumes-from letsencrypt_data \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://yourserver" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1HTTP_ENABLED=false" \
    -e "SERVER1LETSENCRYPT_CERTIFICATES=true" \
    -e "SERVER1CERTIFICATE_FILE=/etc/letsencrypt/live/example.com/fullchain.pem" \
    -e "SERVER1CERTIFICATE_KEY=/etc/letsencrypt/live/example.com/privkey.pem" \
    -e "SERVER1CERTIFICATE_TRUSTED=/etc/letsencrypt/live/example.com/fullchain.pem" \
    --name nginx \
    blacklabelops/nginx
~~~~

> LETSENCRYPT_CERTIFICATES switches on special configuration for letsencrypt certificates.

# References

* [Let’s Encrypt](https://letsencrypt.org/)
* [Letsencrypt-Auto](https://github.com/letsencrypt/letsencrypt)
* [Letsencrypt-Auto Docs](http://letsencrypt.readthedocs.org/en/latest/index.html)
* [Jobber](https://github.com/dshearer/jobber)
* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
