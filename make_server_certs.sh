#!/bin/bash

# Create a Device Certificate for each domain,
# such as example.com, *.example.com, awesome.example.com
# NOTE: You MUST match CN to the domain name or ip address you want to use
openssl genrsa \
  -out all/privkey.pem \
  2048

# Create a request from your Device, which your Root CA will sign
openssl req -new \
  -config openssl.cnf \
  -sha256 \
  -key all/privkey.pem \
  -out all/csr.pem

# Sign the request from Device with your Root CA
openssl x509 \
  -req -in all/csr.pem \
  -sha256 \
  -CA all/my-private-root-ca.cert.pem \
  -CAkey all/my-private-root-ca.privkey.pem \
  -CAcreateserial \
  -out all/cert.pem \
  -days 500

# covert the server certificate to der
#openssl x509 -outform der -in all/cert.pem -out all/cert.der

# Put things in their proper place
cp all/{privkey,cert}.pem server/
cat all/cert.pem > server/fullchain.pem         # we have no intermediates in this case
cp all/my-private-root-ca.cert.pem server/
cp all/my-private-root-ca.cert.pem client/

# create DER format crt for iOS Mobile Safari, etc
#openssl x509 -outform der -in all/my-private-root-ca.cert.pem -out client/my-private-root-ca.crt

# add the certificate and private key into a p12
rm -f all/server.p12
openssl pkcs12 -export -in all/cert.pem -inkey all/privkey.pem -out all/server.p12 -name default -CAfile all/my-private-root-ca.cert.pem -caname root -passout pass:ibm-team 

# needs to be oracle keytool - ibm one seems not to like this incantation
rm -f all/ibm-team-ssl.keystore
keytool.exe -importkeystore -deststorepass ibm-team -destkeypass ibm-team -destkeystore all/ibm-team-ssl.keystore -srckeystore all/server.p12 -srcstoretype PKCS12 -srcstorepass ibm-team

#cp server/cert.pem /d/dev/gadget_server/certs/server/my-server.crt.pem
#cp server/privkey.pem /d/dev/gadget_server/certs/server/my-server.key.pem
#cp server/my-private-root-ca.cert.pem /d/dev/gadget_server/certs/ca/my-root-ca.crt.pem
