source ./init.sh

if [ ! -f "./data/acme/${ACME_DOMAINS[0]}/fullchain.cer" ]
then
    echo "[AutoCert] Certs not issued"
    ./issue.sh
else
    export ACME_MERGED_PARAMS="--cron "

    RunACME
    exit $?    
fi