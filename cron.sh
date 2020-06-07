source ./init.sh

if [ ! -f "./data/acme/${ACME_DOMAINS[0]}/fullchain.cer" ]
then
    echo "[AutoCert] Certs not issued"
    ./issue.sh
else
    export ACME_MERGED_PARAMS="--cron "

    RunACME
    if [ $? -ne 0 ]; then
        echo "[AutoCert] acme.sh failed with code $?"
        exit $? 
    fi

    echo "[AutoCert] acme.sh shell finished"

    pushd "./data/acme/${ACME_DOMAINS[0]}"
    currentTime=$(date +%s)
    modifyTime=$(stat -c %Y "${ACME_DOMAINS[0]}.key")
    timeDiff=$(($currentTime-$modifyTime))
    
    if [ $timeDiff -lt 60 ] || [ ! -f "${ACME_DOMAINS[0]}.pfx" ]; then 
        echo "[AutoCert] Generating pfx for ${ACME_DOMAINS[0]}"
        openssl pkcs12 -export -out "${ACME_DOMAINS[0]}.pfx" -inkey "${ACME_DOMAINS[0]}.key" -in fullchain.cer -passout pass:
    fi
    popd
fi