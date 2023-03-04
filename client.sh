#!/bin/bash

# Client for autocert
export AUTOCERT_ROOT_DIR="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"
pushd "$AUTOCERT_ROOT_DIR"
source ./init.sh

while getopts ":hfs" option; do
   case $option in
        f) # display Help
            export AUTOCERT_FORCE_EXECUTE_SCRIPT=1
        ;;
        s) # display Help
            export AUTOCERT_USE_SLAVE=1
        ;;
        h)
            echo "Usage: $0 [-f] [-s]"
            echo "  -f: force execute after cert update script"
            echo "  -s: use slave git repo"
            exit 0
        ;;
   esac
done


if [ $AUTOCERT_USE_SLAVE ]; then
    export CERT_GIT_ORIGIN="slave"
else
    export CERT_GIT_ORIGIN="master"
fi

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
    echo "[AutoCert] Cloning Cert git ($CERT_GIT_ORIGIN) ..."
    if [ $AUTOCERT_USE_SLAVE ]; then
        git clone --recursive --branch $CERT_GIT_BRANCH "$CERT_GIT_URI_SLAVE" ./data
    else
        git clone --recursive --branch $CERT_GIT_BRANCH "$CERT_GIT_URI" ./data
    fi

    if [ ! -z $CERT_GIT_URI_SLAVE ]; then
        pushd ./data
        git remote add slave "$CERT_GIT_URI_SLAVE"
        popd
    fi

    pushd ./data
        git remote add master "$CERT_GIT_URI"
    popd

    echo "[AutoCert] Repo cloned successfully."
fi


pushd data
GIT_PREVIOUS_VERSION=$(git rev-parse HEAD)
git pull -v --no-rebase "$CERT_GIT_ORIGIN" $CERT_GIT_BRANCH
GIT_CURRENT_VERSION=$(git rev-parse HEAD)
popd

if [ "$GIT_CURRENT_VERSION" == "$GIT_PREVIOUS_VERSION" ] && [ ! $AUTOCERT_FORCE_EXECUTE_SCRIPT ]; then
    echo "[AutoCert] Nothing to update, current verion is $GIT_CURRENT_VERSION"
else
    echo "[AutoCert] Updated certs to version $GIT_CURRENT_VERSION"
    if [ -f "./after-update-cert.sh" ]; then
        echo "[AutoCert] Running cert update callback after-update-cert.sh"
        . ./after-update-cert.sh
    fi
fi

popd