rm -f nginx.error.log apache.error.log apache2.pid
apache2 -d . -k start -X &
sleep 0.2
curl http://localhost:8800/
tail apache.error.log
killall apache2
