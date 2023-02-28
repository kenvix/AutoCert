#!/bin/bash
echo "[AutoCert] Cron for CI version 3"

export AUTOCERT_CI_MODE=1

git config --global user.email "$CERT_GIT_EMAIL"
git config --global user.name "$CERT_GIT_USER"

if [ -f "./deployment.key" ]; then
    echo "[AutoCert] Deployment key file deployment.key found, installing key"
    if [ ! -d ~/.ssh/ ]; then
        mkdir ~/.ssh/
    fi
    if [ -f ~/.ssh/id_rsa ]; then
        mv ~/.ssh/id_rsa ~/.ssh/id_rsa.autocert-backup
    fi
    cp -f "./deployment.key" ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
fi

ExitCIShell() {
    if [ -f ~/.ssh/id_rsa.autocert-backup ]; then
        echo "[AutoCert] Recovering ssh key"
        rm ~/.ssh/id_rsa
        mv ~/.ssh/id_rsa.autocert-backup ~/.ssh/id_rsa
    fi
    exit $1
}

git clone --recursive --branch $CERT_GIT_BRANCH --depth=1 "$CERT_GIT_URI" ./data

if [ $? -ne 0 ]; then
    ErrorCode=$?
    echo "[AutoCert] Checkout Data repo failed $CERT_GIT_URI ($CERT_GIT_BRANCH) with code $ErrorCode"
    ExitCIShell $ErrorCode
fi

chmod -R 777 *.sh
echo "[AutoCert] Files in ./ present:"
ls -al ./

chmod -R 777 ./data
chmod +x ./data/config.sh
echo "[AutoCert] Files in ./data present:"
ls -al ./data

git submodule update --init --recursive
chmod -R 777 ./acme

source ./init.sh
./cron.sh

if [ $? -ne 0 ]; then
    echo "[AutoCert] acme.sh failed with code $?"
    ExitCIShell
fi

pushd ./data

git add .
git commit -m "$CERT_GIT_COMMIT_MESSAGE" -v -a
if [ $? -eq 0 ]; then
    echo "[AutoCert] File changes detected"
    git push --force -v "origin" $CERT_GIT_BRANCH
    ExitCIShell
else
    echo "[AutoCert] No changes to commit."
fi

if [ $CERT_GIT_MAKE_RESULT_ZIP ]; then
    echo "[AutoCert] Making cert artifact zip"
    zip -9 -r ../result.zip *
fi

popd

ExitCIShell