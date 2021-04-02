#!/bin/bash
# Client for autocert
pushd $(cd "$(dirname "$0")";pwd)
source ./init.sh

if [ -f "./deployment.key" ]; then
    if [ ! $CERT_SSH_AGENT_INITIALIZED ]; then
        export CERT_SSH_AGENT_INITIALIZED=1
        ssh-agent bash ./client.sh
        exit $?
    fi

    chmod 600 ./deployment.key
    ssh-add ./deployment.key
fi

if [ ! -f "./data/.git/HEAD" ]; then
    echo "[AutoCert] Cloning Cert git ..."
    git clone --recursive --branch $CERT_GIT_BRANCH --depth=1 "$CERT_GIT_URI" ./data
fi


pushd data
GIT_PREVIOUS_VERSION=$(git rev-parse HEAD)
git reset --hard HEAD || true
git pull -v --no-rebase "origin" $CERT_GIT_BRANCH
GIT_CURRENT_VERSION=$(git rev-parse HEAD)
popd

if [ "$GIT_CURRENT_VERSION" == "$GIT_PREVIOUS_VERSION" ]; then
    echo "[AutoCert] Nothing to update, current verion is $GIT_CURRENT_VERSION"
else
    echo "[AutoCert] Updated certs to version $GIT_CURRENT_VERSION"
    if [ -f "./after-update-cert.sh" ]; then
        echo "[AutoCert] Running cert update callback after-update-cert.sh"
        ./after-update-cert.sh
    fi
fi

popd