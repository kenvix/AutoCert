echo "[AutoCert] Cron for CI"

export AUTOCERT_CI_MODE=1

git config --global user.email "$CERT_GIT_EMAIL"
git config --global user.name "$CERT_GIT_USER"
git clone --recursive --branch $CERT_GIT_BRANCH --depth=1 "$CERT_GIT_SCHEME$CERT_GIT_USER:$CERT_GIT_PASSWORD@$CERT_GIT_URI" ./data

chmod -R +x ./data
ls -al ./data

source ./init.sh
./cron.sh

if [ $? -ne 0 ]
then
    exit $?
fi

cd ./data

git add .
git commit -m "$CERT_GIT_COMMIT_MESSAGE" -v -a
if [ $? -eq 0 ]
then
    echo "[AutoCert] File changes detected"
    git push --force -v "origin" $CERT_GIT_BRANCH
    exit $?
fi