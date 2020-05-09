# Client for autocert

source ./init.sh

if [ ! -f "./data/.git/HEAD" ]; then
    echo "[AutoCert] Cloning Cert git ..."

    if [ -f "./deployment.key" ]; then
        eval `ssh-agent -s`
        ssh-add ./deployment.key
        yes | git clone --recursive --branch $CERT_GIT_BRANCH --depth=1 "$CERT_GIT_URI" ./data
        ssh-add -d deployment.key
    else
        git clone --recursive --branch $CERT_GIT_BRANCH --depth=1 "$CERT_GIT_URI" ./data
    fi
fi


pushd data
GIT_PREVIOUS_VERSION=$(git rev-parse HEAD)
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