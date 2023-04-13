#!/bin/bash

CERTDIR='/cert'

echo "Generating local certs in ${CERTDIR}"

# scortched earth cleanup
sudo rm -rf ${CERTDIR} /tmp/krakend-cert

# generate cert
mkdir -p /tmp/krakend-cert
openssl req -newkey rsa:2048 -new -nodes -x509 -days 365 -out /tmp/krakend-cert/tls.crt -keyout /tmp/krakend-cert/tls.key \
  -subj "/C=US/ST=California/L=Mountain View/O=Your Organization/OU=Your Unit/CN=localhost"

# move cert into place
sudo mkdir ${CERTDIR} 
sudo mv /tmp/krakend-cert/* ${CERTDIR}/
