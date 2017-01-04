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
* newcert: Simply generate a new certificate.
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

Example `newcert`:

~~~~
$ docker run -it \
    -p 80:80 \
    -p 443:443 \
    --name letsencrypt \
    -e "LETSENCRYPT_DOMAIN1=subdomain1.example.com" \
    blacklabelops/letsencrypt newcert
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

# Letsencrypt And Nginx

Note: This will not work inside on your local comp. You will have to do this inside your target environment.

Steps:

1. Create Docker volume for certificates
1. Create certificates.
1. Start Nginx with certificates.
1. Start Container in renewal mode
1. Start Cron Container for reloading Nginx config

First create a volume for your certificates:

~~~~
$ docker volume create letsencrypt_certificates
~~~~

> Creates volume on hosts hard disk.

Then start the letsencrypt container once and create the certificates.

~~~~
$ docker run --rm \
    -p 80:80 \
    -p 443:443 \
    -v letsencrypt_certificates:/etc/letsencrypt \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=example.com" \
    blacklabelops/letsencrypt install
~~~~

> This container will handshake with letsencrypt.org and an account and the certificate when successful.

Then create additional volume for acme handshakes:

~~~~
$ docker volume create letsencrypt_challenges
~~~~

Now you can use the certificate for your reverse proxy! The additional volume will be used for renewal.

~~~~
$ docker run -d \
    -p 443:443 \
    -p 80:80 \
    -v letsencrypt_certificates:/etc/letsencrypt \
    -v letsencrypt_challenges:/var/www/letsencrypt \
    -e "NGINX_REDIRECT_PORT80=true" \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://yourserver" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1HTTP_ENABLED=true" \
    -e "SERVER1LETSENCRYPT_CERTIFICATES=true" \
    -e "SERVER1CERTIFICATE_FILE=/etc/letsencrypt/live/example.com/fullchain.pem" \
    -e "SERVER1CERTIFICATE_KEY=/etc/letsencrypt/live/example.com/privkey.pem" \
    -e "SERVER1CERTIFICATE_TRUSTED=/etc/letsencrypt/live/example.com/fullchain.pem" \
    --name nginx \
    blacklabelops/nginx
~~~~

> LETSENCRYPT_CERTIFICATES switches on special configuration for letsencrypt certificates. E.g. in order to accept certificate challenges

Now start letsencrypt in renewal mode, this will renew certificates each month!

~~~~
$ docker run -d \
    -v letsencrypt_certificates:/etc/letsencrypt \
    -v letsencrypt_challenges:/var/www/letsencrypt \
    -e "LETSENCRYPT_WEBROOT_MODE=true" \
    -e "LETSENCRYPT_EMAIL=dummy@example.com" \
    -e "LETSENCRYPT_DOMAIN1=example.com" \
    --name letsencrypt \
    blacklabelops/letsencrypt
~~~~

> This container will handshake with letsencrypt.org each month on the 15th and renewal the certificate when successful.

Finally start a cron container that will reload the Nginx configuration after the certificates have been renewed!

~~~~
$ docker run -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "JOB_NAME1=ReloadNginx" \
    -e "JOB_COMMAND1=docker exec nginx nginx -s reload" \
    -e "JOB_TIME1=0 0 2 15 * *" \
    -e "JOB_ON_ERROR1=Continue" \
    blacklabelops/jobber:docker
~~~~

> Reloads Nginx configuration each month on the 15th over Docker without restarting Nginx! In order to achieve high availability!

# References

* [Let’s Encrypt](https://letsencrypt.org/)
* [Letsencrypt-Auto](https://github.com/letsencrypt/letsencrypt)
* [Letsencrypt-Auto Docs](http://letsencrypt.readthedocs.org/en/latest/index.html)
* [Jobber](https://github.com/dshearer/jobber)
* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
