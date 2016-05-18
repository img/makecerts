#!/bin/bash
FQDN=greenfront.edinburgh.uk.ibm.com

# make directories to work from
mkdir -p server/ client/ all/

# Create your very own Root Certificate Authority
openssl genrsa \
  -out all/my-private-root-ca.privkey.pem \
  2048

# Self-sign your Root Certificate Authority
# Since this is private, the details can be as bogus as you like
openssl req \
    -config openssl_imgCA.cnf \
  -sha256 \
  -x509 \
  -new \
  -nodes \
  -key all/my-private-root-ca.privkey.pem \
  -days 3650 \
  -out all/my-private-root-ca.cert.pem
