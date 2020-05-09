# Client for autocert

source ./init.sh

if [ ! -f "./data/.git/HEAD" ]; then
    echo "[AutoCert] Cloning Cert git ..."

    if [ -f "./deployment.key" ]; then
        ssh-agent $(ssh-add ./deployment.key; git clone --recursive --branch $CERT_GIT_BRANCH --depth=1 "$CERT_GIT_URI" ./data; ssh-add -d ./deployment.key )
    else
        git clone --recursive --branch $CERT_GIT_BRANCH --depth=1 "$CERT_GIT_URI" ./data
    fi
else
    cd data
    git.exe pull -v --no-rebase "origin" $CERT_GIT_BRANCH   
fi

if [ -f "./after-update-cert.sh" ]; then
    echo "[AutoCert] Running cert update callback after-update-cert.sh"
    ./after-update-cert.sh
fi