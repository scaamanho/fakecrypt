#!/bin/bash

# DEFINE DEFAULT VALUES
ROOT_CA_DIR=rootCA
CA_DIR=CA
CERTS_DIR=certs


# Check if exist previous CA
FILE=./rootCA/private/rootCA.key
if [ -f "$FILE" ]; then
  read -p "A previous CA allreay exist. This will delete previous CA. Continue? (y/N)" overwrite

  if [ "$overwrite" = "y" ]
  then
    rm -rf ${CA_DIR}
    rm -rf ${ROOT_CA_DIR}
  else
    echo "Done!."
    exit 0
  fi
fi

# Create estucture directory

mkdir -p ${ROOT_CA_DIR}/{certs,db,private}
chmod 700 ${ROOT_CA_DIR}/private
touch ${ROOT_CA_DIR}/db/db
touch ${ROOT_CA_DIR}/db/db.attr

mkdir -p ${CA_DIR}/{certs,db,private}
chmod 700 ${CA_DIR}/private
touch ${CA_DIR}/db/db
touch ${CA_DIR}/db/db.attr

mkdir ${CERTS_DIR}


countryName="ME"
localityName="Podgorica"
commonName="Fake Root CA"

caOrganizationName="Fake Networks"
caOrganizationalUnitName="Signatures Department"
caCommonName="Fake Networks CA"

# ASK CONFIG VALUES
read -p "Country Name [${countryName}]" inputValue
if [ "$inputValue" != "" ]
then
  countryName=$inputValue
fi

read -p "City Name [${localityName}]" inputValue
if [ "$inputValue" != "" ]
then
  localityName=$inputValue
fi

read -p "Root Common Name [${commonName}]" inputValue
if [ "$inputValue" != "" ]
then
  commonName=$inputValue
fi

read -p "CA Organization Name [${caOrganizationName}]" inputValue
if [ "$inputValue" != "" ]
then
  caOrganizationName=$inputValue
fi

read -p "CA Name [${caOrganizationalUnitName}]" inputValue
if [ "$inputValue" != "" ]
then
  caOrganizationalUnitName=$inputValue
fi

read -p "CA Common Name [${caCommonName}]" inputValue
if [ "$inputValue" != "" ]
then
  caCommonName=$inputValue
fi






# Create configuration files
cat > ${ROOT_CA_DIR}/root-csr.conf << EOF
[ req ]
encrypt_key = no
utf8 = yes
string_mask = utf8only
prompt=no
distinguished_name = root_dn
x509_extensions = extensions
[ root_dn ]
# Country Name (2 letter code)
countryName = ${countryName}
# Locality Name (for example, city)
localityName = ${localityName}
# Organization Name (for example, company)
0.organizationName = ${commonName}
# Name for the certificate
commonName = ${commonName}
[ extensions ]
keyUsage = critical,keyCertSign,cRLSign
basicConstraints = critical,CA:TRUE
subjectKeyIdentifier = hash
EOF


cat > ${CA_DIR}/CA-csr.conf << EOF
[ req ]
encrypt_key = no
default_bits = 2048
default_md = sha256
utf8 = yes
string_mask = utf8only
prompt = no
distinguished_name = ca_dn
[ ca_dn ]
0.organizationName = "${caOrganizationName}"
organizationalUnitName = "${caOrganizationalUnitName}"
commonName = "${caCommonName}"
EOF

cat > ${CA_DIR}/rootCA.conf << EOF
[ ca ]
default_ca = the_ca
[ the_ca ]
dir = ${ROOT_CA_DIR}
private_key = \$dir/private/rootCA.key
certificate = \$dir/rootCA.crt
new_certs_dir = \$dir/certs
serial = \$dir/db/crt.srl
database = \$dir/db/db
default_md = sha256
policy = policy_any
email_in_dn = no
[ policy_any ]
domainComponent = optional
countryName = optional
stateOrProvinceName = optional
localityName = optional
organizationName = optional
organizationalUnitName = optional
commonName = optional
emailAddress = optional
[ ca_ext ]
keyUsage                = critical,keyCertSign,cRLSign
basicConstraints        = critical,CA:true
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always
EOF

cat > ${CERTS_DIR}/CA.conf << EOF
[ ca ]
default_ca = the_ca
[ the_ca ]
dir = ${CA_DIR}
private_key = \$dir/private/CA.key
certificate = \$dir/CA.crt
new_certs_dir = \$dir/certs
serial = \$dir/db/crt.srl
database = \$dir/db/db
unique_subject = no
default_md = sha256
policy = any_pol
email_in_dn = no
copy_extensions = copy
[ any_pol ]
domainComponent = optional
countryName = optional
stateOrProvinceName = optional
localityName = optional
organizationName = optional
organizationalUnitName = optional
commonName = optional
emailAddress = optional
[ leaf_ext ]
keyUsage = critical,digitalSignature,keyEncipherment
basicConstraints = CA:false
extendedKeyUsage = serverAuth,clientAuth
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always
[ ca_ext ]
keyUsage                = critical,keyCertSign,cRLSign
basicConstraints        = critical,CA:true,pathlen:0
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always
EOF

echo "Creating ROOT CA CERTIFICATE"
# CREATE ROOT CA CERTIFICATE
openssl req -x509 -sha256 -days 36500 -newkey rsa:3072 \
    -config ${ROOT_CA_DIR}/root-csr.conf -keyout ${ROOT_CA_DIR}/private/rootCA.key \
    -out ./${ROOT_CA_DIR}/rootCA.crt

# SHOW CERTIFICATE CREATED
openssl x509 -in ${ROOT_CA_DIR}/rootCA.crt -text -noout   


echo "Creating INTERMEDIATE CA CERTIFICATE"

#  create a certificate signing request
openssl req -new -config ${CA_DIR}/CA-csr.conf -out ${CA_DIR}/CA.csr \
        -keyout ${CA_DIR}/private/CA.key

# sign the certificate in the request with the root certificate
openssl ca -config ${CA_DIR}/rootCA.conf -days 36500 -create_serial \
    -in ${CA_DIR}/CA.csr -out ./${CA_DIR}/CA.crt -extensions ca_ext -notext


# Link certificates together to have the certificate chain in one file
cat ${CA_DIR}/CA.crt ${ROOT_CA_DIR}/rootCA.crt >${CA_DIR}/CA.pem