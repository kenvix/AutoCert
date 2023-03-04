#!/bin/sh
#
# *** For DSM v7.x ***
#
# How to use this script:
#  1. Get your 3 PEM files ready to copy over from your local machine/update server (privkey.pem, fullchain.pem, cert.pem)
#     and put into a directory (this will be $CERT_DIRECTORY).
#  2. Ensure you have a user setup on synology that has ssh access (and ssh access is setup).
#     This user will need to be able to sudo as root (i.e. add this line to sudoers, <USER> is the user you create):
#       <USER> ALL=(ALL) NOPASSWD: /var/services/homes/<USER>/replace_certs.sh
#  3. Call this script as follows:
#     sudo scp ${CERT_DIRECTORY}/{privkey,fullchain,cert}.pem $USER@$SYNOLOGY_SERVER:/tmp/ \
#     && sudo scp replace_synology_ssl_certs.sh $USER@$SYNOLOGY_SERVER:~/ \
#     && ssh $USER@$SYNOLOGY_SERVER 'sudo ./replace_synology_ssl_certs.sh'

# Script start.

REVERSE_PROXY=/usr/syno/etc/certificate/ReverseProxy
FQDN_DIR=/usr/syno/etc/certificate/system/FQDN
DEFAULT_DIR=
DEFAULT_DIR_NAME=$(cat /usr/syno/etc/certificate/_archive/DEFAULT)
if [ "$DEFAULT_DIR_NAME" != "" ]; then
    DEFAULT_DIR="/usr/syno/etc/certificate/_archive/${DEFAULT_DIR_NAME}"
fi

mv /tmp/{privkey,fullchain,cert}.pem /usr/syno/etc/certificate/system/default/
if [ "$?" != 0 ]; then
    echo "Halting because of error moving files"
    exit 1
fi
chown root:root /usr/syno/etc/certificate/system/default/{privkey,fullchain,cert}.pem
if [ "$?" != 0 ]; then
    echo "Halting because of error chowning files"
    exit 1
fi
echo "Certs moved from /tmp & chowned."

if [ -d "${FQDN_DIR}/" ]; then
    echo "Found FQDN directory, copying certificates to 'certificate/system/FQDN' as well..."
    cp /usr/syno/etc/certificate/system/default/{privkey,fullchain,cert}.pem "${FQDN_DIR}/"
    chown root:root "${FQDN_DIR}/"{privkey,fullchain,cert}.pem
fi

if [ -d "$DEFAULT_DIR" ]; then
    echo "Found upload dir (used for Application Portal): $DEFAULT_DIR_NAME, copying certs to: $DEFAULT_DIR"
    cp /usr/syno/etc/certificate/system/default/{privkey,fullchain,cert}.pem "$DEFAULT_DIR/"
    chown root:root "$DEFAULT_DIR/"{privkey,fullchain,cert}.pem
else
    echo "Did not find upload dir (Application Portal): $DEFAULT_DIR_NAME"
fi

if [ -d "$REVERSE_PROXY" ]; then
    echo "Found reverse proxy certs, replacing those:"
    for proxy in $(ls "$REVERSE_PROXY"); do
        echo "Replacing $REVERSE_PROXY/$proxy"
        cp /usr/syno/etc/certificate/system/default/{privkey,fullchain,cert}.pem "$REVERSE_PROXY/$proxy"
        chown root:root "$REVERSE_PROXY/$proxy/"{privkey,fullchain,cert}.pem
    done
else
    echo "No reverse proxy directory found"
fi

echo -n "Rebooting all the things..."
/usr/syno/bin/synosystemctl restart nginx
/usr/syno/bin/synosystemctl restart nmbd
/usr/syno/bin/synosystemctl restart avahi
/usr/syno/bin/synosystemctl reload ldap-server
echo " done"