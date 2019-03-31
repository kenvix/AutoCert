# Client for autocert

source ./init.sh

if [ ! -f "./data/.git/HEAD" ]
then
    echo "[AutoCert] Cert git not cloned"
    git clone --recursive --branch $CERT_GIT_BRANCH --depth=1 "$CERT_GIT_SCHEME$CERT_GIT_USER:$CERT_GIT_PASSWORD@$CERT_GIT_URI" ./data
else
    cd data
    git.exe pull -v --no-rebase "origin" $CERT_GIT_BRANCH   
fi