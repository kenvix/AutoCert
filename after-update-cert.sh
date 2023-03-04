#!/bin/bash
CurrentDir="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"
cd "$CurrentDir"

# for Linux nginx
if ! command -v nginx &> /dev/null
then
    echo "[Nginx] Nginx could not be found, ignore"
else 
    echo "[Nginx] reloading"
    nginx -s reload
fi

# for IIS on Micorosft Windows
if ! command -v powershell.exe &> /dev/null
then
    echo "[powershell] powershell could not be found, ignore"
else 
    echo "[powershell] Execute: powershell.exe after-update-cert.ps1"
    if [ -f "after-update-cert.ps1" ]; then
        powershell.exe -NonInteractive -NoLogo -executionpolicy bypass -NoProfile -File "after-update-cert.ps1"
    fi
fi

# for Synology DSM
if ! command -v synosystemctl &> /dev/null
then
    echo "[synosystemctl] synosystemctl could not be found, not in synology dsm, ignore"
else 
    echo "[synosystemctl] Installing cert for DSM"
    SYNO_CERT_ROOT="/tmp"
    cp -r -f "$CERT_PATH_CER" "$SYNO_CERT_ROOT/cert.pem"
    cp -r -f "$CERT_PATH_KEY" "$SYNO_CERT_ROOT/privkey.pem"
    cp -r -f "$CERT_PATH_FULLCHAIN" "$SYNO_CERT_ROOT/fullchain.pem"
    ./replace_synology_ssl_certs.sh
    rm -f "$SYNO_CERT_ROOT/cert.pem"
    rm -f "$SYNO_CERT_ROOT/privkey.pem"
    rm -f "$SYNO_CERT_ROOT/fullchain.pem"
fi