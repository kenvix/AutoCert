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