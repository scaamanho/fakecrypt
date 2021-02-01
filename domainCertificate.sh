#!/bin/bash

DOMAIN=vcap.me
CERTS_DIR=certs

read -p "Domain Name [${DOMAIN}]:" inputValue
if [ "$inputValue" != "" ]
then
  DOMAIN=$inputValue
fi

# Check if exist CA 
# Check if exist previous CA
FILE=./${CERTS_DIR}/CA.conf
if [ ! -f "$FILE" ]; then
  read -p "CA Authority don't exist. Create a new One (Y/n)" overwrite

  if [ "$overwrite" = "n" ]
  then
    echo "Can't Create ${DOMAIN} certificate."
    exit 0
  else
    ./createCA.sh
  fi
fi


mkdir -p ${CERTS_DIR}/${DOMAIN}

cat > ./${CERTS_DIR}/${DOMAIN}/${DOMAIN}-csr.conf << EOF
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
openssl req -new -config ${CERTS_DIR}/${DOMAIN}/${DOMAIN}-csr.conf -out ${CERTS_DIR}/${DOMAIN}/${DOMAIN}.csr \
        -keyout ${CERTS_DIR}/${DOMAIN}/${DOMAIN}.key

# sign the server certificate in the request with the intermediate CA certificate
openssl ca -config certs/CA.conf -days 36500 -create_serial \
    -in ${CERTS_DIR}/${DOMAIN}/${DOMAIN}.csr -out certs/${DOMAIN}/${DOMAIN}.crt -extensions leaf_ext -notext

# Link certificates together to have the certificate chain in one file
cat ${CERTS_DIR}/${DOMAIN}/${DOMAIN}.crt CA/CA.pem >${CERTS_DIR}/${DOMAIN}/${DOMAIN}.pem

# check what information the certificate contains
openssl x509 -in certs/${DOMAIN}/${DOMAIN}.crt -text -noout

# make sure that the DNS entries for SAN are correct
openssl x509 -in certs/${DOMAIN}/${DOMAIN}.crt -text -noout | grep DNS

echo "All cerficate files are in certs/${DOMAIN} folder"