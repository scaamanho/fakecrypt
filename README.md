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
createCA.sh
```
