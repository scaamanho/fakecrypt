# FakeCrypt
![FakeCrypt Logo](assets/logo250.png) 

Become in Certificate Authority and sing your own valid certificates

## Why Become in your own CA

Sometimes you need several certificates for your machines , and you are tired of deal with invalid certificates exceptions, showed in connections or browsers when you are testing a local enviroment with SSL/HTTPS or even in your local network.

Becoming in your own CA, you can sing several certificates for your diferents host/domains, and you only need import your your `rootCA.crt` file in your system to validate all your signed certificates.

TODO: Image


## TL;TR

Generate a certificate for vcap.me [this domain points to 127.0.0.1]

### Install

```sh
$> wget https://raw.githubusercontent.com/scaamanho/fakecrypt/main/fakecrypt \
&& chmod +x fakecrypt \
&& sudo mv fakecrypt /usr/local/bin
```

### Execute

Use enter to use default values

```sh
$> fakecrypt
```

All your certificates files will be store in `$HOME/fakecrypt/` directory.

### Export CA.crt and domain certificates and key

```sh
$> fakecrypt root crt > fakecryptCA.crt
$> fakecrypt cert crt vcap.me > vcap.me.crt
$> fakecrypt cert pem vcap.me > vcap.me.pem
$> fakecrypt cert key vcap.me > vcap.me.key
```

import `fakecryptCA.crt` in your system and set `vcap.me.crt` and `vcap.me.key` in your server

### Help

```sh
$> fakecrypt --help
$> fakecrypt root --help
$> fakecrypt ca --help
$> fakecrypt cert --help
```

## Manage your own CA
At first run FakeCrypt check if exist a Certified Authority, and ask you for cretion values, you can press enter and use defaults or set your our owns.

FakeCrypt provide some commands to inspect, export and delete (use with carefull) CA authorities

### View Root CA certificate

```bash
$>fakecrypt root view
Root CA Info:
------------------------------------------------------------------
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            5f:3c:fd:28:17:36:36:63:da:74:dc:2f:22:5a:c7:6b:52:59:5a:94
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = CA, L = Alert, O = FakeCrypt Root CA, CN = FakeCrypt Root CA
        Validity
            Not Before: Feb  2 13:54:53 2021 GMT
            Not After : Jan  9 13:54:53 2121 GMT
        Subject: C = CA, L = Alert, O = FakeCrypt Root CA, CN = FakeCrypt Root CA
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (3072 bit)
                Modulus:
                    00:9b:e9:0a:be:c1:88:19:bc:52:66:22:ad:97:54:
....
```
### Export Root CA Certificate

You can get rootCA.crt form your filesystem, but you can also generate a copy with the command

```bash
$>fakecrypt root crt > my_rootCA.crt
```

### Reset Root CA Certificate

**Use with careful**. Delete all created authorities and signed certificates and create a new Root and Intermediate authority

```bash
$>fakecrypt root reset
```

### Intermediate Authority

You also can show, inspect, export and reset Intermediate Authority with the commands:

```sh
$>fakecrypt ca view
$>fakecrypt ca crt > myCA.crt
$>fakecrypt ca pem > myCA.pem
```

## Manage your own domains certificates

FakeCrypt provide a list of commands to create, manage and export domain certificates

```sh
$>fakecrypt cert create domain.ext
$>fakecrypt cert list
$>fakecrypt cert view domain.ext
$>fakecrypt cert crt domain.ext > my_domain.crt
$>fakecrypt cert pem domain.ext > my_domain.pem
$>fakecrypt cert key domain.ext > my_domain.key
```

### Domains that point to 127.0.0.1

These domains point to localhost, and can be used generate your local machine certificates

* [*.]localtest.me
* [*.]127-0-0-1.org.uk
* [*.]vcap.me
* [*.]yoogle.com
* [*.]lvh.me
* [*.]lacolhost.com
* domaincontrol.com
* [*.]127.0.0.1.xip.io

### Custom Domains

If you need customize your own domains with multiple machines in a local network, you can register domains or subdomains for free in:

* <https://my.freenom.com/>
* <https://www.dynu.com/>
* <https://www.duckdns.org/> - Can't use subdomains feature.
* [*.][host_ip].xip.io

and point them to your machines.

## Import Certificate Authorities in your System
[TODO:]
### Debian/Ubuntu

```sh
sudo mkdir /usr/local/share/ca-certificates/extra
sudo cp rootCA.crt /usr/local/share/ca-certificates/extra/
sudo update-ca-certificates
```

### CentOS/RHEL

```sh
cp rootCA.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract
```

### Windows

#### Chrome/Edge/IE

Chrome, Edge, and Internet Explorer use the Windows certificate store.

To import the certificate to the Windows certificate store, follow these steps:

Copy the rootCA.crt certificate file to the computer.
Double-click the certificate file.
Select Install Certificate.
Select Local Machine and then Next.
Select Place all certificates in the following store, and then Browse.
Select Trusted Root Certification Authorities and then Next.
Select Finish.

#### Firefox

Firefox uses its own certificate manager.

Copy the rootCA.crt certificate file to the computer.
Open Tools > Options.
Select Privacy & Security and browse to Certificates.
Select View Certificates.
Go to the Authorities tab.
Select Import.
Browse to the rootCA.crt certificate file and select Open.
Select Trust this CA to identify websites.
Select OK.
### Android

### Mac

### iOS

## Config your domain certificate in your server
[TODO:]
### NGINX

### Traefik


## How to customize FakeCrypt

[TODO:]

## Backup your data

[TODO:]



## References

* [Creating TLS/SSL certificates for ThreatShield](https://help.f-secure.com/product.html#business/threatshield/latest/en/concept_E8E015C30E05412190F22C5DFC36AC0B-threatshield-latest-en) 
* [How to Create Your Own SSL Certificate Authority for Local HTTPS Development](https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/)