rm -f nginx.error.log apache.error.log apache2.pid
apache2 -d . -k start -X &
sleep 0.2
curl -iL http://localhost:8800/index.html
curl -iL http://localhost:8800/.well-known/acme-challenge/1234
tail apache.error.log
killall apache2
