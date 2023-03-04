#!/bin/bash
export AUTOCERT_ROOT_DIR="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

if [ -z $AUTOCERT_INITED ]
then
    if [ ! -x "./config.sh" ]; then
        echo "Error: ./config.sh not found or not executable"
        echo "Please modify config.sh.example and copy it to ./config.sh"
        exit 170
    fi
    export AUTOCERT_INITED=1
fi


source ./config.sh

# if _secret.sh exist then include
if [ -f "./_secret.sh" ]; then
    source ./_secret.sh
fi

# if CERT_GIT_URI_SLAVE is set
if [ ! -z $CERT_GIT_URI_SLAVE ]; then
    # if CERT_GIT_URI_SLAVE_PUSH is not set
    if [ -z $CERT_GIT_URI_SLAVE_PUSH ]; then
        export CERT_GIT_URI_SLAVE_PUSH="$CERT_GIT_URI_SLAVE"
    fi
fi

# if CERT_GIT_URI_PUSH is not set
if [ -z $CERT_GIT_URI_PUSH ]; then
    export CERT_GIT_URI_PUSH="$CERT_GIT_URI"
fi


export CERT_PATH="$AUTOCERT_ROOT_DIR/data/acme/${ACME_DOMAINS[0]}"
export CERT_DOMAIN="${ACME_DOMAINS[0]}"
export CERT_PATH_FULLCHAIN="$CERT_PATH/fullchain.cer"
export CERT_PATH_CER="$CERT_PATH/${ACME_DOMAINS[0]}.cer"
export CERT_PATH_KEY="$CERT_PATH/${ACME_DOMAINS[0]}.key"
export CERT_PATH_PFX="$CERT_PATH/${ACME_DOMAINS[0]}.pfx"

RunACME(){
    if [ "$ACME_MERGED_PARAMS" ]
    then
        echo "$ $ACME_MERGED_PARAMS"
        ./acme.sh $ACME_MERGED_PARAMS 
        return $?
    fi
}