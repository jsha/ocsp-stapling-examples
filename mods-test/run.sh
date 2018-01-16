rm -f apache.error.log apache2.pid
cat > apache2.conf apache2.base.conf - <<EOF
Redirect / https://eff.org/
ProxyPass "/" "http://google.com/"
RewriteEngine on
RewriteRule "/.well-known/acme-challenge/(.*)" "/\$1" [END]
EOF

echo "good response" > 1234

apache2 -d . -k start -X &
sleep 0.2

RESPONSE=$(curl -sL http://localhost:8800/.well-known/acme-challenge/1234 --max-redirs 5)
if [[ $RESPONSE != "good response" ]] ; then
	echo "bad response"
fi

tail apache.error.log
killall apache2
