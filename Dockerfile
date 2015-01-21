# VERSION 0.2
# DOCKER-VERSION
# AUTHOR:         Based on work by Sam Alba <sam@docker.com>
# DESCRIPTION:    Image with docker-registry project and dependecies behind an Nginx proxy
# TO_BUILD:       docker build -rm -t nginx-registry .
# TO_RUN:         docker run -p 80:80 -p 443:443 nginx-registry

FROM phusion/baseimage:0.9.15

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN mkdir -p /opt/certs/  \
			 /root/templates/

# Update
RUN apt-get update \
# Install pip
    && apt-get install -y \
        swig \
        python-pip \
# Install deps for backports.lmza (python2 requires it)
        python-dev \
        libssl-dev \
        liblzma-dev \
        libevent1-dev \
        nginx 

COPY . /docker-registry
COPY ./config/boto.cfg /etc/boto.cfg

# Install core
RUN pip install /docker-registry/depends/docker-registry-core

# Install registry
RUN pip install file:///docker-registry#egg=docker-registry[bugsnag,newrelic,cors]

RUN patch \
 $(python -c 'import boto; import os; print os.path.dirname(boto.__file__)')/connection.py \
 < /docker-registry/contrib/boto_header_patch.diff

ENV DOCKER_REGISTRY_CONFIG /docker-registry/config/config_sample.yml
ENV SETTINGS_FLAVOR dev
ENV DEPLOYMENT_SERVER_NAME demo.lab1
ENV DEPLOYMENT_DOMAIN test.com
ENV DEPLOYMENT_ENV dev

# Docker registry port
EXPOSE 5000

# Nginx proxy port
EXPOSE 443 80

COPY ./config/nginx.conf /etc/nginx/nginx.conf

## Install Nginx and Docker-Registry runit services.
COPY ./runit/nginx /etc/service/nginx/run
COPY ./runit/nginx-log-forwarder /etc/service/nginx-log-forwarder/run
COPY ./runit/docker-registry /etc/service/docker-registry/run

RUN chmod +x /etc/service/*/run

COPY ./templates/registry.nginx.conf.template /root/templates/registry.nginx.conf.template

COPY ./scripts/my_*.sh /etc/my_init.d/
RUN chmod +x /etc/my_init.d/my_*.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*