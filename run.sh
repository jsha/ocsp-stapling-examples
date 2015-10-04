#!/bin/bash
# Run a local Apache and Nginx configured with OCSP stapling, to make sure it
# works properly.
# Preconditions: cert.pem and cert-key.pem in the current directory should
# represent a valid certificate with OCSP information and a running OCSP server.
# Certificates issued from a local Boulder instance work great, so long as Boulder
# is still running locally and still has data about those certs in its DB (i.e.,
# you have not run create_db.sh recently).
# Also, test-ca.pem in the current directory should be the CA cert from which they
# were issued.
# Publicly trusted certificates should work, but you will have to tweak the
# construction of cert-fullchain.pem in run.sh.
#
# Output should contain two instances of:
#   OCSP Response Status: successful (0x0)
# Along with a bunch of other output.
#
# Also, Nginx will produce a spurious error, "could not open error log file."
# This is expected and does not affect operation.
cd $(dirname $0)
rm -f nginx.error.log apache.error.log apache2.pid
touch mime.types
# See comment in nginx.conf for why we do this.
cat cert.pem test-ca.pem > cert-fullchain.pem
trap 'kill $(jobs -p)' EXIT
apache2 -d . -k start -X &
nginx -c nginx.conf -p . &
sleep 0.2
tail --retry -F nginx.error.log &
tail --retry -F apache.error.log &
# Nginx requires one priming request before it can return OCSP
openssl s_client -connect localhost:9443 -tlsextdebug -status < /dev/null >/dev/null
echo "~~~~ Trying Nginx stapling ~~~~"
openssl s_client -connect localhost:9443 -tlsextdebug -status < /dev/null | head -20
# Apache gets it on the first try
echo "~~~~ Trying Apache stapling ~~~~"
openssl s_client -connect localhost:8443 -tlsextdebug -status < /dev/null | head -20
