FROM centos:6.7
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

# Property permissions
ENV CONTAINER_USER=letsencrypt
ENV CONTAINER_UID=1000
ENV CONTAINER_GROUP=letsencrypt
ENV CONTAINER_GID=1000

# install dev tools
RUN yum install -y epel-release && \
    yum install -y \
    golang \
    make \
    git \
    sudo \
    mercurial  && \
    yum clean all && rm -rf /var/cache/yum/* && \
    /usr/sbin/groupadd --gid $CONTAINER_GID $CONTAINER_GROUP && \
    /usr/sbin/useradd --uid $CONTAINER_UID --gid $CONTAINER_GID --create-home --shell /bin/bash $CONTAINER_GROUP && \
    /usr/sbin/usermod -aG wheel $CONTAINER_USER && \
    echo "%wheel ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "Defaults:$CONTAINER_USER !requiretty" >> /etc/sudoers

# install Jobber
ENV JOBBER_HOME=/opt/jobber
ENV JOBBER_LIB=$JOBBER_HOME/lib
ENV GOPATH=$JOBBER_LIB
ENV LETSENCRYPT_HOME=/opt/letsencrypt

RUN mkdir -p $JOBBER_HOME && \
    mkdir -p $JOBBER_LIB && \
    mkdir -p $LETSENCRYPT_HOME && \
    chown -R $CONTAINER_UID:$CONTAINER_GID $JOBBER_HOME $LETSENCRYPT_HOME && \
    cd $JOBBER_LIB && \
    go get github.com/dshearer/jobber && \
    make -C src/github.com/dshearer/jobber install-bin DESTDIR=$JOBBER_HOME && \
    cd $LETSENCRYPT_HOME && \
    git clone https://github.com/letsencrypt/letsencrypt && \
    /opt/letsencrypt/letsencrypt/letsencrypt-auto

USER $CONTAINER_USER
COPY imagescripts/docker-entrypoint.sh /opt/jobber/docker-entrypoint.sh
ENTRYPOINT ["/opt/jobber/docker-entrypoint.sh"]
CMD ["jobberd"]
