#!/bin/bash

SCRIPT_DIR=`dirname $0`
cd ${SCRIPT_DIR}

source config
source function.inc

apt-get -y install curl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce docker-compose
apt-get -y install vlan ssh openssh-server openssl
modprobe 8021q

## generate nginx config
func_nginx_cfg

mkdir -p $SSL_PATH

## ssl
## generate root CA key
openssl genrsa -out $SSL_PATH/root-ca.key 4096
## generate root CA certivicate
openssl req -x509 -new -nodes -key $SSL_PATH/root-ca.key -sha256 -days 365 -out $SSL_PATH/root-ca.crt -subj "/C=UA/ST=Kharkov/L=Kharkov/O=Podrepny/OU=web/CN=root_cert/"
## generate nginx key
openssl genrsa -out $SSL_PATH/web.key 2048
## generate nginx certificate signing request
openssl req -new -out $SSL_PATH/web.csr -key $SSL_PATH/web.key -subj "/C=UA/ST=Kharkov/L=Kharkov/O=Podrepny/OU=web/CN=$HOST_NAME/"
## signing a nginx CSR with a root certificate
openssl x509 -req -in $SSL_PATH/web.csr -CA $SSL_PATH/root-ca.crt -CAkey $SSL_PATH/root-ca.key -CAcreateserial -out $SSL_PATH/web.crt -days 365 -sha256 -extfile <(echo -e "authorityKeyIdentifier=keyid,issuer\nbasicConstraints=CA:FALSE\nkeyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\nsubjectAltName = @alt_names\n[ alt_names ]\nDNS.1 = $HOST_NAME\nDNS.2 = $EXT_IP_ADDR\nIP.1 = $EXT_IP_ADDR")
## combining two certificates (nginx and root CA) to web.pem
cat $SSL_PATH/web.crt $SSL_PATH/root-ca.crt > $SSL_PATH/web.pem


## deploy docker conteiner apache2 nginx
volume

$NGINX_LOG_DIR
