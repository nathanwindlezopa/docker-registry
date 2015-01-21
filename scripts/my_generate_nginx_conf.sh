#! /bin/bash

sed -e "s/%deployment_server_name%/$DEPLOYMENT_SERVER_NAME/g"  -e "s/%deployment_env%/$DEPLOYMENT_ENV/g" -e "s/%deployment_domain%/$DEPLOYMENT_DOMAIN/g" /root/templates/registry.nginx.conf.template > /etc/nginx/sites-enabled/registry.nginx.conf