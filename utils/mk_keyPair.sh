
openssl genrsa -out private.key 1024
openssl req -new -x509 -key private.key -out publickey.crt -days 365

