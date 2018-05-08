#!/bin/bash

SCRIPT_DIR=`dirname $0`
cd ${SCRIPT_DIR}
WRK_DIR_PATH=$(pwd)

source config
source function.inc

SSL_DIR="$WRK_DIR_PATH/certs"
SSL_DIR_DOCKER="/etc/nginx/certs"
NGINX_CFG_DIR="$WRK_DIR_PATH/etc"
NGINX_CFG_FILE="$WRK_DIR_PATH/etc/nginx.conf"
NGINX_CFG_FILE_DOCKER="/etc/nginx/nginx.conf"
NGINX_CFG_TEMPLATE_FILE="$WRK_DIR_PATH/template/nginx.conf.template"
NGINX_LOG_DIR_DOCKER=/var/log/nginx
DOCKER_SRV_APACHE_NAME="web"
DOCKER_SRV_APACHE_PORT="80"
DOCKER_SRV_NGINX_NAME="proxy"
DOCKER_SRV_NGINX_PORT="443"
DOCKER_SRV_NGINX_LOG_DIR="/var/log/nginx"
DOCKER_YML_FILE="$WRK_DIR_PATH/docker-compose.yml"
DOCKER_YML_TEMPLATE_FILE="$WRK_DIR_PATH/template/docker-compose.yml.template"

## install components
apt-get update
apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce docker-compose bridge-utils
apt-get -y install ssh openssh-server openssl

# create dir tree and files
func_dir_tree_gen

## generate ssl CA and web
func_ssl_gen

## generate nginx config
eval "echo \"$(cat ${NGINX_CFG_TEMPLATE_FILE})\"" > ${NGINX_CFG_FILE}
#command: /bin/bash -c "envsubst < /etc/nginx/conf.d/mysite.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"

## generate docker-compose.yml from template
eval "echo \"$(cat ${DOCKER_YML_TEMPLATE_FILE})\"" > ${DOCKER_YML_FILE}

## run docker-compose
docker-compose up -d

exit 0
