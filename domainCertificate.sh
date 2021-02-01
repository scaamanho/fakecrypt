#!/bin/sh

if [ "$#" -ne 1 ]
then
  echo "Usage: Must supply a domain"
  exit 1
fi

DOMAIN=$1

mkdir -p certs/${DOMAIN}

cat > ./certs/${DOMAIN}/${DOMAIN}-csr.conf << EOF
[ req ]
default_bits = 2048
encrypt_key = no
default_md = sha256
utf8 = yes
string_mask = utf8only
prompt = no
distinguished_name = server_dn
req_extensions = server_reqext
[ server_dn ]
commonName = *.$DOMAIN 
[ server_reqext ]
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = serverAuth,clientAuth
subjectKeyIdentifier = hash
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.$DOMAIN
DNS.2 = *.m.$DOMAIN
DNS.3 = $DOMAIN
EOF

# create a certificate signing request
openssl req -new -config certs/${DOMAIN}/${DOMAIN}-csr.conf -out certs/${DOMAIN}/${DOMAIN}.csr \
        -keyout certs/${DOMAIN}/${DOMAIN}.key

# sign the server certificate in the request with the intermediate CA certificate
openssl ca -config certs/CA.conf -days 36500 -create_serial \
    -in certs/${DOMAIN}/${DOMAIN}.csr -out certs/${DOMAIN}/${DOMAIN}.crt -extensions leaf_ext -notext

# Link certificates together to have the certificate chain in one file
cat certs/${DOMAIN}/${DOMAIN}.crt CA/CA.pem >certs/${DOMAIN}/${DOMAIN}.pem

# check what information the certificate contains
openssl x509 -in certs/${DOMAIN}/${DOMAIN}.crt -text -noout

# make sure that the DNS entries for SAN are correct
openssl x509 -in certs/${DOMAIN}/${DOMAIN}.crt -text -noout | grep DNS