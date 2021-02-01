# FakeCrypt
Become in Certificate Authority and sing your own valid certificates

## Why Become in your own CA

Most of times you need a valid certificate for your all your machines in your local network, and you are tired of deal with invalid certificates showed in connections or browsers when you are testing in your local enviroment or even in your local network.

Becoming in your own CA, you can sing several certificates for your diferents domains, and you only need import your your `CA.pem` or your `CA.crt` file in your system to validate all your signed certificates.

TODO: Image

## Create your own CA

This step mus be only runned once, and is highly recomendable keep a backup of directories `rootCA` and `CA` due is where your CA certificates resides.

To create your CA Authority run script `createCA.sh`.

This script will ask for needed values to customize your CA.
If you use enter, will be use de default values

```sh
$>./createCA.sh

Country Name [ME]:
City Name [Podgorica]:
Root Common Name [Fake Root CA]:
CA Organization Name [Fake Networks]:
CA Name [Signatures Department]:
CA Common Name [Fake Networks CA]:

Creating ROOT CA CERTIFICATE
....
Creating INTERMEDIATE CA CERTIFICATE
....

```

## Sing your own domains certificates

Once you run `createCA.sh` now you can create your domain certificates for all domains that you want.

For that run `domainCertificate.sh` this will pront for domain name, and all your files and certificates needed for this domain will be under `certs/domain-name.ext`. If any domain values is provider will be use default domain `vcap.me`

```sh
$>./domainCertificate.sh
Domain Name [vcap.me]:
Generating a RSA private key
...
                DNS:*.vcap.me, DNS:*.m.vcap.me, DNS:vcap.me
All cerficate files are in certs/vcap.me folder
```

This script allow domain name use subdomains

### Domains that point to 127.0.0.1

These domains point to localhost

* [*.]localtest.me
* [*.]127-0-0-1.org.uk
* [*.]vcap.me
* [*.]yoogle.com
* [*.]lvh.me
* [*.]lacolhost.com
* domaincontrol.com
* [*.]127.0.0.1.xip.io

### Custom Domains

If you need customize your own domains you, can register domains or subdomains for free in:

* <https://my.freenom.com/>
* <https://www.dynu.com/>
* <https://www.duckdns.org/>