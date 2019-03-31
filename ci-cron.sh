git config --global user.email "$CERT_GIT_EMAIL"
git config --global user.name "$CERT_GIT_USER"
git clone --depth=1 "$CERT_GIT_SCHEME$CERT_GIT_USER:$CERT_GIT_PASSWORD@$CERT_GIT_URI" ./data

./cron.sh
