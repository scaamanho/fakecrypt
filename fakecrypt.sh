#!/bin/bash

# DEFINE DEFAULT VALUES
DOMAIN=vcap.me
ROOT_CA_DIR=~/fakecrypt/rootCA
CA_DIR=~/fakecrypt/CA
CERTS_DIR=~/fakecrypt/certs

countryName="ME"
localityName="Podgorica"
commonName="Fake Root CA"
caOrganizationName="Fake Networks"
caOrganizationalUnitName="Signatures Department"
caCommonName="Fake Networks CA"

# $1 text to show - $2 default value
function read_value ()
{
  read -p "${1} [${2}]" READ_VALUE
  if [ "${READ_VALUE}" = "" ]
  then
    READ_VALUE=$2
  fi
}

function create_ca ()
{
  # Check if exist previous CA
  FILE=${ROOT_CA_DIR}/private/rootCA.key
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

  # ASK CONFIG VALUES
  read_value "Country Name" "${countryName}"
  countryName=${READ_VALUE}
  read_value "City Name" "${localityName}"
  localityName=${READ_VALUE}
  read_value "Root Common Name" "${commonName}"
  commonName=${READ_VALUE}
  read_value "CA Organization Name" "${caOrganizationName}"
  caOrganizationName=${READ_VALUE}
  read_value "CA Name" "${caOrganizationalUnitName}"
  caOrganizationalUnitName=${READ_VALUE}
  read_value "CA Common Name" "${caCommonName}"
  caCommonName=${READ_VALUE}


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
      -out ${ROOT_CA_DIR}/rootCA.crt
  # SHOW CERTIFICATE CREATED
  openssl x509 -in ${ROOT_CA_DIR}/rootCA.crt -text -noout   
  echo "Creating INTERMEDIATE CA CERTIFICATE"
  #  create a certificate signing request
  openssl req -new -config ${CA_DIR}/CA-csr.conf -out ${CA_DIR}/CA.csr \
          -keyout ${CA_DIR}/private/CA.key
  # sign the certificate in the request with the root certificate
  openssl ca -config ${CA_DIR}/rootCA.conf -days 36500 -create_serial \
      -in ${CA_DIR}/CA.csr -out ${CA_DIR}/CA.crt -extensions ca_ext -notext
  # Link certificates together to have the certificate chain in one file
  cat ${CA_DIR}/CA.crt ${ROOT_CA_DIR}/rootCA.crt >${CA_DIR}/CA.pem

  # TODO: Log where ca certificate is

}


function _header ()
{
  echo "#############################"
  echo "#         FakeCrypt         #"
  echo "#############################"
  echo " Set domain name to create certificate, import CA certificate and enjoy your thrusted domain"
  #TODO:
}


_header
# Read Domain Name
read_value "Domain Name" "${DOMAIN}"
DOMAIN=${READ_VALUE}


# Check if exist CA 
# Check if exist previous CA
FILE=${CERTS_DIR}/CA.conf
if [ ! -f "$FILE" ]; then
  read -p "CA Authority don't exist. Create a new One (Y/n)" overwrite

  if [ "$overwrite" = "n" ]
  then
    echo "Can't Create ${DOMAIN} certificate."
    exit 0
  else
    create_ca
  fi
fi


mkdir -p ${CERTS_DIR}/${DOMAIN}

cat > ${CERTS_DIR}/${DOMAIN}/${DOMAIN}-csr.conf << EOF
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
openssl ca -config ${CERTS_DIR}/CA.conf -days 36500 -create_serial \
    -in ${CERTS_DIR}/${DOMAIN}/${DOMAIN}.csr -out ${CERTS_DIR}/${DOMAIN}/${DOMAIN}.crt -extensions leaf_ext -notext

# Link certificates together to have the certificate chain in one file
cat ${CERTS_DIR}/${DOMAIN}/${DOMAIN}.crt ${CA_DIR}/CA.pem >${CERTS_DIR}/${DOMAIN}/${DOMAIN}.pem

# check what information the certificate contains
openssl x509 -in ${CERTS_DIR}/${DOMAIN}/${DOMAIN}.crt -text -noout

# make sure that the DNS entries for SAN are correct
openssl x509 -in ${CERTS_DIR}/${DOMAIN}/${DOMAIN}.crt -text -noout | grep DNS

echo "All CA certificate files are in ${CA_DIR} folder [CA.pem(CA.crt+rootCA.crt)]"
echo "All Server cerficate files are in ${CERTS_DIR}/${DOMAIN} folder"
